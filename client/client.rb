## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby


class Object
  def to_b
    compare_value = self.class == String ? self.downcase : self
    case compare_value
      when "yes", "true", "ok", true, "1", 1, :true, :ok, :yes
        true
      else
        false
    end
  end
end




require 'curses'
require 'require_all'
require './lib/base_process.rb'
require './lib/utils.rb'
require './lib/job.rb'
require_all './lib/view/'
require_all './lib/action/'
require './account/account_process.rb'
require './lib/dev_log.rb'
require './game_tcp_client.rb'
require './display.rb'
require 'json'
require 'logger'
include Curses

class Character
  attr_reader :x, :y, :id
  def initialize(user_id, x, y)
    @x = x
    @y = y
    @message_log = MessageLog.new
  end
  def move(x,y)
    @x = @x + x
    @y = @y + y
    @message_log.add("move to #{@x},#{@y}")
    #@tcp_client.move(@id, @x, @y)
  end
  def get_message
    @message_log.get
  end
end

class MessageLog
  def initialize
    @messages = []
    @max = 5
  end
  def add(message)
    @messages << message
  end
  def get
    first = @messages.count < 5 ? 0 : @messages.count - 5
    @messages[first..@messages.count]
  end
end


class ClientEvent
  attr_reader :queue
  def initialize
    @queue = nil
  end
  def start
    create_wait_client_event_process
  end
  def create_wait_client_event_process
    @queue = Queue.new
    Thread.start do
      stdscr.keypad true
      while(key = Curses.getch)
        @queue.push(key)
      end
    end
  end
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
begin
  #for test start
#init_screen

  logger = Logger.new('./log/tcp_server_log.txt')
  logger.level = Logger::WARN

  tcp_client = GameTcpClient.new
  client_event = ClientEvent.new
  client_event.start

  account_process = AccountProcess.new(tcp_client)
  account_process.set_client_queue(client_event.queue)
  account_process.start

  user_id = Utils::r_find(account_process.action_results, :user_id)
  user_name = Utils::r_find(account_process.action_results, :user_name)
  password = Utils::r_find(account_process.action_results, :password)
  job_id = Utils::r_find(account_process.action_results, :job_id)
  logger.error "#{account_process.action_results.to_s}"
  logger.error "user_id =#{user_id}, user_name = #{user_name}, password => #{password}, job_id => #{job_id}"

  #abort
  #game_process = GameProcess.new(tcp_client)
  #game_process.set_client_queue(client_event.queue)
  #game_process.start





  display = Display.new(tcp_client.get_display_info)
  display.write(user_list=[], message_list=[], sub_message_list=[])
#display.initialize_view

  #user_id = tcp_client.get_new_user_id

  server_queue = create_receive_process
  tcp_client.user_login(user_id)
  position = tcp_client.init_user_position(user_id)
  chara = Character.new(user_id, position['x'], position['y'])
  logger.error "initial position #{position.to_s}"


sub_message_list = ["user_id:#{user_id}", "job:#{Job::JobList[1]}", "user_name:#{user_name}","LEVEL:1","HP:100","STRENGTH:10","MP:20"]


  loop do
    if server_queue.empty? == false
      message = server_queue.pop
      if message.instance_of?(Hash) && message['cmd'] == 'update_all_user_position'
        logger.error "move message #{message['params'].to_s}}"
        display.write(message['params'], chara.get_message, sub_message_list)
      else
      end
    elsif client_event.queue.empty? == false
      key = client_event.queue.pop
      case key
      when Curses::Key::RIGHT
        tcp_client.move(user_id, chara.x + 1 , chara.y) and chara.move(1,0)
      when Curses::Key::LEFT
        tcp_client.move(user_id, chara.x - 1 , chara.y) and chara.move(-1,0)
      when Curses::Key::UP
        tcp_client.move(user_id, chara.x, chara.y - 1) and chara.move(0, -1)
      when Curses::Key::DOWN
        tcp_client.move(user_id, chara.x, chara.y + 1) and chara.move(0, 1)
      else
        abort
        close_screen
      end
    end
    #sleep 0.1
  end
ensure
  #close_screen
end
