# -*- coding: utf-8 -*-
require 'socket'
require 'yaml'
require 'json'
require './game_tcp_client.rb'
require 'logger'

class User
  attr_reader :id, :ip, :x, :y, :port
  def initialize(user_id, ip, port)
    @id = user_id
    @ip = ip
    @port = '10006'
    @x = 0
    @y = 0
  end
  def update_position(x,y)
    @x = x
    @y = y
  end
end

class UserList
  def initialize
    @user_list = []
    @last_user_id = 0
    @tcp_client = GameTcpClient.new
    @logger = Logger.new('./log/user_list_log.txt')
    @logger.level = Logger::WARN
  end
  def get_new_user_by_ip(ip, port)
    @last_user_id = @last_user_id + 1
    user = User.new(@last_user_id, ip, port)
    @user_list << user
    user.id
  end
  def update_by_id(user_id, x, y)
    user = @user_list.detect{|t| t.id == user_id}
    user.update_position(x,y)
  end
  def send_all_current_position
    @logger.debug @user_list.map{|user| {:user_id => user.id, :ip => user.ip, :x => user.x, :y => user.y } }.to_s
    @tcp_client.send_all_current_position(@user_list.map{|user| {:user_id => user.id, :ip => user.ip, :x => user.x, :y => user.y } }, @user_list.map{|user| {:ip => user.ip, :port => user.port}})
  end
end

class GameTcpServer
  def initialize
    temp = YAML.load_file('user.yml')
    @port = temp['accepter_setting']['port']
    @user_list = UserList.new
    @logger = Logger.new('./log/tcp_server_log.txt')
    @logger.level = Logger::WARN
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
      #message = message.chomp if message != nil
      if message['cmd'] == 'new_user_id'
        @logger.error 'new_user_id accepted'
        puts "accept from #{remote_ip} ok"
        user_id = @user_list.get_new_user_by_ip(remote_ip, '10004')
        result = {:user_id => user_id}.to_json
        client.puts result
      elsif message['cmd'] == 'move'
        @logger.error 'move accepted'
        @user_list.update_by_id(message['params']['user_id'], message['params']['x'], message['params']['y'])
        @user_list.send_all_current_position
      else
        @logger.error "else message #{message.to_s}"
        puts message
        puts 'unknown'
      end
      sleep 3
      puts 'hrer'
      # クライアントの接続を閉じる
      #client.close
    end
  end
end

ts=GameTcpServer.new
ts.start

