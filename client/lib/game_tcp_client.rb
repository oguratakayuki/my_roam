## -*- coding: utf-8 -*-
require 'socket'
require 'timeout'
require 'yaml'
require 'json'
require 'logger'

class GameTcpClient
  class TokenParamsInvalid < StandardError;end
  def initialize
    @ip = '192.168.12.161'
    @port = '10004'
    @server_ip = '192.168.12.161'
    @server_port = '10005'
    @logger = Logger.new('./log/tcp_client_log')
    @logger.level = Logger::WARN
  end

  def get_new_user_id
    message = {'cmd' => "new_user_id"}.to_json
    result = self.send(message)
    result = JSON.parse(result)['user_id']
    return result
  end


  def get_display_info
    message = {'cmd' => "get_display_info"}.to_json
    result = self.send(message)
    result = JSON.parse(result)
    return result
  end

  def init_user_position(user_id)
    message = {'cmd' => "init_user_position", 'params' => {'user_id' => user_id } }.to_json
    result = self.send(message)
    result = JSON.parse(result)
    @logger.error "init_user_position return=#{result.to_s}"
    return result
  end

  def check_user_name(user_name)
    message = {'cmd' => "check_user_name", 'params' => {'user_name' => user_name, 'need_return' => true} }.to_json
    result = self.send(message)
    result = JSON.parse(result)
    @logger.error "check_user_name return=#{result.to_s}"
    return result['result'].to_b
  end

  def user_registration(user_name, password)
    message = {'cmd' => "user_registration", 'params' => {'user_name' => user_name, 'password' => password, 'need_return' => true} }.to_json
    result = self.send(message)
    result = JSON.parse(result)
    user_id = result['result']['user_id'].to_i
    #unless result.to_i > 1
    #  raise StandardError, 'fail to create user'
    #end
    return user_id
  end

  def user_update(user_id, attributes)
    message = {'cmd' => "user_update", 'params' => {'user_id' => user_id, 'attributes' => attributes} }.to_json
    self.send_only(message)
  end

  def user_login(user_id)
    message = {'cmd' => "user_login", 'params' => {'user_id' => user_id} }.to_json
    self.send_only(message)
  end

  def user_change_job(user_id, job_id)
    message = {'cmd' => "user_change_job", 'params' => {'user_id' => user_id, 'job_id' => job_id} }.to_json
    self.send_only(message)
  end


  def move(user_id, x, y)
    message = {'cmd' => "move", :params => {:user_id => user_id, :x => x, :y => y}}.to_json
    result = self.send(message)
    result = JSON.parse(result)['move_status']
    @logger.error "move return=#{result.to_s}"
    return result
  end

  def attack(user_id, x, y, direction)
    message = {'cmd' => "attack", :params => {:user_id => user_id, :x => x, :y => y, :direction => direction}}.to_json
    result = self.send_only(message)
  end

  def send(message_with_json, ip=nil, port=nil)
    @server_ip = ip if ip
    @server_port = port if port
    s = TCPSocket.open(@server_ip, @server_port)
    s.puts(message_with_json)
    result = s.gets
    s.close
    return result
  end

  def send_only(message_with_json, ip=nil, port=nil)
    @server_ip = ip if ip
    @server_port = port if port
    s = TCPSocket.open(@server_ip, @server_port)
    s.puts(message_with_json)
    s.close
    return
  end

  def create_receive_process
    #q = Queue.new
    #Thread.start do
    #  server = TCPServer.new(10006)
    #  begin
    #    while true
    #      client = server.accept
    #      message = client.gets
    #      next if message == nil
    #      message = message.chomp
    #      message = JSON.parse(message)
    #      client.puts 'ok'
    #      q.push(message)
    #      client.close
    #    end
    #  rescue
    #  ensure
    #    client.close
    #  end
    #end
    #return q
    server_queue = Queue.new
    server = TCPServer.new(10006)
    Thread.start do
      while true
        # クライアントからの接続をacceptする
        sock = server.accept
        # クライアントからのデータを全て受け取る
        message = sock.gets
        next if message == nil
        message = message.chomp
        message = JSON.parse(message)
        server_queue.push(message)
        # acceptしたソケットを閉じる
        sock.close
      end
    end
    server_queue
  end




end
