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
  end

  def get_new_user_id
    message = {'cmd' => "new_user_id"}.to_json
    result = self.send(message)
    #puts 'new_user_id result = ' + result.to_s
    result = JSON.parse(result)['user_id']
    #puts 'after parse'
    return result
  end

  def move(user_id, x, y)
    message = {'cmd' => "move", :params => {:user_id => user_id, :x => x, :y => y}}.to_json
    result = self.send(message)
  end

  def send_all_current_position(user_list, ip_port_list)

    @logger = Logger.new('./log/tcp_client_log.txt')
    @logger.level = Logger::WARN
    message = {'cmd' => 'update_all_user_position', :params => user_list}.to_json
    ip_port_list.each do |ip_port|
      @logger.error "send_All_current_position!!!ip=#{ip_port[:ip]},port=#{ip_port[:port]},user_list=#{user_list.to_s}"
      self.send(message, ip_port[:ip], ip_port[:port])
    end
  end

  def send(message_with_json, ip=nil, port=nil)
    @server_ip = ip if ip
    @server_port = port if port
    #@logger.error "to open #{@server_ip},#{@server_port}"
    #puts @server_ip
    #puts @server_port
    s = TCPSocket.open(@server_ip, @server_port)
    #puts 'start'
    #puts message_with_json
    s.puts(message_with_json)
    result = s.gets
    #puts "server result is #{result.to_s}"
    s.close
    return result
  end

end
