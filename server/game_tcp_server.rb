# -*- coding: utf-8 -*-
require 'socket'
require 'yaml'
require 'json'
require 'logger'
require './user_list.rb'

class GameTcpServer
  def initialize
    temp = YAML.load_file('user.yml')
    @port = temp['accepter_setting']['port']
    @user_list = UserList.new
    @logger = Logger.new('./log/tcp_server_log.txt')
    @logger.level = Logger::WARN
  end

  def send_message_to_all_client(cmd, ip_port_list, user_list)
    if cmd == 'update_all_user_position'
      message = {'cmd' => 'update_all_user_position', :params => user_list}.to_json
    end
    ip_port_list.each do |ip_port|
      @logger.error "send_message_to_all_client!!!ip=#{ip_port[:ip]},user_list=#{user_list.to_s}"
      self.send_only(message, ip_port[:ip])
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
    loop do
      # クライアントからの入力を出力(1行のみ)
      client = server.accept
      sock_domain, remote_port, remote_hostname, remote_ip = client.peeraddr
      message = client.gets
      puts message
      next if message == nil
      puts 'server accept ok'
      message = message.chomp
      message = JSON.parse(message)
      if message['cmd'] == 'new_user_id'
        @logger.error 'new_user_id accepted'
        puts "accept from #{remote_ip} ok"
        user_id = @user_list.get_new_user_by_ip(remote_ip, '10004')
        result = {:user_id => user_id}.to_json
        client.puts result
      elsif message['cmd'] == 'move'
        @logger.error 'move accepted'
        @user_list.update_by_id(message['params']['user_id'], message['params']['x'], message['params']['y'])
        send_message_to_all_client('update_all_user_position', @user_list.ips_and_ports, @user_list.positions)
      else
        @logger.error "else message #{message.to_s}"
        puts message
        puts 'unknown'
      end
      #sleep 3
      puts 'hrer'
      # クライアントの接続を閉じる
      #client.close
    end
  end
end

ts=GameTcpServer.new
ts.start

