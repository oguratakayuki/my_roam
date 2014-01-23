## -*- coding: utf-8 -*-
require 'socket'
require 'timeout'
require 'yaml'
require 'json'
require 'logger'

class GameTcpClient
  def initialize
    @ip = '192.168.12.25'
    @port = '10004'
    @server_ip = '192.168.12.25'
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




  def move(user_id, x, y)
    message = {'cmd' => "move", :params => {:user_id => user_id, :x => x, :y => y}}.to_json
    result = self.send(message)
    result = JSON.parse(result)['move_status']
    @logger.error "move return=#{result.to_s}"
    return result
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
end
