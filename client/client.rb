## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby

require 'curses'
require './game_tcp_client.rb'
require './display.rb'
require 'json'

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

def create_wait_client_event_process
  q = Queue.new
  Thread.start do
    stdscr.keypad true
    while(key = Curses.getch)
      q.push(key)
    end
  end
  return q
end

begin
  #for test start
#init_screen
  tcp_client = GameTcpClient.new
  display = Display.new(tcp_client.get_display_info)
  display.write(user_list=[], message_list=[])
  #display.initialize_view
  user_id = tcp_client.get_new_user_id
  position = tcp_client.init_user_position(user_id)
  chara = Character.new(user_id, position['x'], position['y'])
  client_queue = create_wait_client_event_process
  server_queue = create_receive_process
  loop do
    if server_queue.empty? == false
      message = server_queue.pop
      if message.instance_of?(Hash) && message['cmd'] == 'update_all_user_position'
        display.write(message['params'], chara.get_message)
      else
      end
    elsif client_queue.empty? == false
      key = client_queue.pop
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
