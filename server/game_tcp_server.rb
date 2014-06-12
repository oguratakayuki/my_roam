# -*- coding: utf-8 -*-
require 'socket'
require 'yaml'
require 'json'
require 'logger'
require './user_list.rb'
require './map.rb'

class GameTcpServer
  def initialize
    @setting = YAML.load_file('server_setting.yml')
    @receive_port = @setting['tcp_receive_port']
    @user_list = UserList.new
    @logger = Logger.new('./log/tcp_server_log.txt')
    @logger2 = Logger.new('./log/enemy_log.txt')
    @logger.level = Logger::WARN
    @map = Map.new
  end

  def send_message_to_all_client(cmd, ips, map_list)
    if cmd == 'update_all_user_position'
      message = {'cmd' => 'update_all_user_position', :params => map_list}.to_json
    end
    if ips
      ips.each do |ip|
        if ip[:ip]
          @logger.error "send_message_to_all_client!!!ip=#{ip[:ip]},user_list=#{map_list.to_s}"
          self.send_only(message, ip[:ip])
        end
      end
    end
  end
  def send_only(message_with_json, ip)
    s = TCPSocket.open(ip, 10006)
    s.puts(message_with_json)
    s.close
    return
  end

  def start
    # 新しいサーバ接続をポート10001で開く
    server = TCPServer.open(@receive_port=10005)
    # クライアントからの接続を待つ
    set_enemy
    set_effect_remove_thread
    while true
      # クライアントからの入力を出力(1行のみ)
      Thread.start(server.accept) do |sock|
        sock_domain, remote_port, remote_hostname, remote_ip = sock.peeraddr
        puts "sock_domain=#{sock_domain.to_s},remote_port=#{remote_port.to_s},remote_hostname=#{remote_hostname.to_s},remote_ip=#{remote_ip.to_s}"
        message = sock.gets
        puts message
        next if message == nil
        puts 'server accept ok'
        message = message.chomp
        message = JSON.parse(message)
        if message['cmd'] == 'new_user_id'
          @logger.error 'new_user_id accepted'
          puts "accept from #{remote_ip} ok"
          user = @user_list.get_new_user_by_ip(remote_ip, '10004')
          result = {:user_id => user.id}.to_json
          sock.puts result
        elsif message['cmd'] == 'move'
          @logger.error 'move accepted'
          user = @user_list.find(message['params']['user_id'])
          move_status = @map.move('user', user.id, user.x, user.y, message['params']['x'], message['params']['y'])
          if move_status
            user.update_position(message['params']['x'], message['params']['y'])
          end
          result = {:move_status => move_status}.to_json
          sock.puts result
          if move_status
            send_message_to_all_client('update_all_user_position', @user_list.ips, @map.export)
          end
        elsif message['cmd'] == 'get_display_info'
          window_info = Hash.new
          window_info[:main_position_x] = @setting['window_info']['main_position_x']
          window_info[:main_position_y] = @setting['window_info']['main_position_y']
          window_info[:main_width] = @setting['window_info']['main_width']
          window_info[:main_height] = @setting['window_info']['main_height']

          window_info[:sub_position_x] = @setting['window_info']['sub_position_x']
          window_info[:sub_position_y] = @setting['window_info']['sub_position_y']
          window_info[:sub_width] = @setting['window_info']['sub_width']
          window_info[:sub_height] = @setting['window_info']['sub_height']

          window_info[:side_position_x] = @setting['window_info']['side_position_x']
          window_info[:side_position_y] = @setting['window_info']['side_position_y']
          window_info[:side_width] = @setting['window_info']['side_width']
          window_info[:side_height] = @setting['window_info']['side_height']

          result = window_info.to_json
          sock.puts result
        elsif message['cmd'] == 'init_user_position'
          #position決定
          position = @map.find_free_space.sample
          @map.move('user', message['params']['user_id'], nil, nil, position['x'], position['y'])
          #position = {'x' => 3, 'y' => 4}
          #更新
          @user_list.update_by_id(message['params']['user_id'], position['x'], position['y'])
          #送信
          position = position.to_json
          #新規ユーザーにはpositionを返す
          sock.puts position
          send_message_to_all_client('update_all_user_position', @user_list.ips, @map.export)
        elsif message.key?('cmd')
          puts "accept method is " + message['cmd']
          if self.methods.include?(message['cmd'].to_sym)
            result = send(message['cmd'].to_sym, message['params'], remote_ip)
            puts "method is over , result = #{result.to_s}"
            puts message['params'].keys.methods.to_s
            if message['params'].keys.include?('need_return')
              puts "now try to return result #{result.to_s}"
              sock.puts result
            else
              puts 'no return'
            end
          else
            puts 'method is not defined'
          end
        else
          @logger.error "else message #{message.to_s}"
          puts message
        end
        sock.close
      end
    end
  end
  def check_user_name(params, remote_ip)
    ret = @user_list.check_user_name(params['user_name'])
    ret = {:result => ret.to_s}.to_json
    #ret
  end
  def user_registration(params, remote_ip)
    user_id = @user_list.user_registration(params['user_name'], params['password'], remote_ip)
    ret = {:result => {:user_id => user_id.to_s}}.to_json
    #ret
  end
  def user_update(params, remote_ip)
    user = @user_list.user_update(params['user_id'], params['attributes'])
    #ret
  end
  def user_login(params, remote_ip)
    user = @user_list.user_login(params['user_id'])
puts 'USER LOGIN IS CALLED params =' + params.to_s
  end
  def user_change_job(params, remote_ip)
    @user_list.user_change_job(params['user_id'], params['job_id'])
  end

  def attack(params, remote_ip)
    #"user_id":2,"x":57,"y":24,"direction":"back"
    attacker_user_id = params[:user_id]
    pos = @map.x_y_with_direction(params['x'], params['y'], params['direction'])
    if pos == {}
      puts "ERROR POSITION ATTACK FAIL!!!!!!!!!!!!!!!!!!!!"
      return
    else
      puts "POSITION OK!!!!!!!!!!!!!!!!!#{pos.to_s}"
    end
    attacked_user_id = @map.find_user_id(pos[:x], pos[:y])
    puts "!!!!!!!attacked user_id = #{attacked_user_id.to_s}"
    puts "!!!!!!!attacked user_id = #{attacked_user_id.to_s}"
    if attacked_user_id
      @user_list.attack(attacker_user_id, attacked_user_id)
      puts 'attack success'
      @map.add_attacked_effect(attacked_user_id)
    else
      weapon_id = 1
      puts 'start to write attack fail effect'
      @map.add_attack_fail_effect(pos[:x], pos[:y], weapon_id, params['direction'])
    end
    #exist? enemy?
    send_message_to_all_client('update_all_user_position', @user_list.ips, @map.export)
  end


  def set_effect_remove_thread
    Thread.start do
      while true
        sleep 0.5
        puts "count down effect start"
        @map.count_down_effect
      end

    end
  end

  def set_enemy
    Thread.start do

      #position決定
      @logger.error "enemy"
      #enemy = Enemy.new
      enemy = @user_list.get_new_enemy
      @logger.error "enemy id #{enemy.id}"
      position = @map.find_free_space.sample
      @map.move('enemy', enemy.id, nil, nil, position['x'], position['y'])
      @user_list.update_by_id(enemy.id, position['x'], position['y'])
      while true
        sleep 2.5
        Signal.trap(:TSTP) do
          puts "敵など見せます"
          puts ''
          puts "SIGTSTOP"
          puts "SIGTSTOP(ctrl+z)"
          puts ''
          @map.dump
          puts ''
          enemy.to_s
          puts ''
          puts ''
          puts "enemy pos x = #{enemy.x}, y = #{enemy.y}"
          #exit(0)
        end

        #key = [:left, :right, :up, :down].sample
        #next_pos = enemy.next_pos_by_key(key)
        action_info = enemy.next_action
        if action_info[:type] == 'walk'
          next_pos = action_info[:params][:next_pos]
          move_status = @map.move('enemy', enemy.id, enemy.x, enemy.y, next_pos[:x], next_pos[:y])
          if move_status
            puts "!!!ENEMY MOVE OK x=#{next_pos[:x]},y=#{next_pos[:y]}"
            puts @map.export.to_s
            enemy.update_position(next_pos[:x], next_pos[:y])
            send_message_to_all_client('update_all_user_position', @user_list.ips, @map.export)
            puts "!!ENEMY MOVE SEND END"
          end
        end
      end
    end
  end
end

ts=GameTcpServer.new
ts.start

