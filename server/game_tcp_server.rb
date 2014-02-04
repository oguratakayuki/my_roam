# -*- coding: utf-8 -*-
require 'socket'
require 'yaml'
require 'json'
require 'logger'
require './user_list.rb'
require './map.rb'

class GameTcpServer
  def initialize
    temp = YAML.load_file('user.yml')
    @port = temp['accepter_setting']['port']
    @user_list = UserList.new
    @logger = Logger.new('./log/tcp_server_log.txt')
    @logger.level = Logger::WARN
    @map = Map.new
  end

  def send_message_to_all_client(cmd, ip_port_list, user_list)
    if cmd == 'update_all_user_position'
      message = {'cmd' => 'update_all_user_position', :params => user_list}.to_json
    end
    ip_port_list.each do |ip_port|
      if ip_port[:ip]
        @logger.error "send_message_to_all_client!!!ip=#{ip_port[:ip]},user_list=#{user_list.to_s}"
        self.send_only(message, ip_port[:ip])
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
    server = TCPServer.open(@port=10005)
    # クライアントからの接続を待つ
    set_enemy
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
          move_status = @map.move(user.id, user.x, user.y, message['params']['x'], message['params']['y'])
          if move_status
            user.update_position(message['params']['x'], message['params']['y'])
          end
          result = {:move_status => move_status}.to_json
          sock.puts result
          if move_status
            send_message_to_all_client('update_all_user_position', @user_list.ips_and_ports, @user_list.infos)
          end
        elsif message['cmd'] == 'get_display_info'
          window_info = Hash.new
          window_info[:main_position_x] = 50
          window_info[:main_position_y] = 15
          window_info[:main_width] = 60
          window_info[:main_height] = 30
          window_info[:sub_position_x] = 50
          window_info[:sub_position_y] = 45
          window_info[:sub_width] = 60
          window_info[:sub_height] = 10

          window_info[:side_position_x] = 120
          window_info[:side_position_y] = 15
          window_info[:side_width] = 20
          window_info[:side_height] = 30


          result = window_info.to_json
          sock.puts result
        elsif message['cmd'] == 'init_user_position'
          #position決定
          position = @map.find_free_space.sample
          @map.move(message['params']['user_id'], nil, nil, position['x'], position['y'])
          #position = {'x' => 3, 'y' => 4}
          #更新
          @user_list.update_by_id(message['params']['user_id'], position['x'], position['y'])
          #送信
          position = position.to_json
          #新規ユーザーにはpositionを返す
          sock.puts position
          send_message_to_all_client('update_all_user_position', @user_list.ips_and_ports, @user_list.infos)
        else
          @logger.error "else message #{message.to_s}"
          puts message
          puts 'unknown'
        end
        sock.close
        puts 'hrer'
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
      @map.move(enemy.id, nil, nil, position['x'], position['y'])
      @user_list.update_by_id(enemy.id, position['x'], position['y'])
      while true
        sleep 0.5
        #key = [:left, :right, :up, :down].sample
        #next_pos = enemy.next_pos_by_key(key)
        action_info = enemy.next_action
        if action_info[:type] == 'walk'
          next_pos = action_info[:params][:next_pos]
          move_status = @map.move(enemy.id, enemy.x, enemy.y, next_pos[:x], next_pos[:y])
          if move_status
            enemy.update_position(next_pos[:x], next_pos[:y])
            send_message_to_all_client('update_all_user_position', @user_list.ips_and_ports, @user_list.infos)
          end
        end
      end
    end
  end
end

ts=GameTcpServer.new
ts.start

