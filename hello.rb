## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby

require "curses"
require "./game_tcp_client.rb"
require 'json'

include Curses

class Display
  def initialize
    @max_width = 58
    @max_height = 28
  end
end

class Character
  attr_reader :x, :y, :id
  def initialize(x,y)
    @tcp_client = GameTcpClient.new
    @id = @tcp_client.get_new_user_id
    @x = x
    @y = y
    @message_log = MessageLog.new
  end
  def move(x,y)
    @x = @x + x
    @y = @y + y
    @message_log.add("move to #{@x},#{@y}")
    @tcp_client.move(@id, @x, @y)
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

def write_screen(user_list)
  #[{"user_id"=>1, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>2, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>3, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}]
  init_screen
  Curses.init_screen
  stdscr.keypad true
  win = Window.new(height=30,width=60, y=15 , x=50 )
  win.box(?|, ?-)
  user_list.each do |user|
    #puts "user_id = #{user['user_id']}"
    win.setpos(user['y'], user['x'])
    win.addstr(user['user_id'].to_s)
  end
  sleep 1.5
  win.refresh
  sleep 1.5
  win.close
end

def write_sub(message_list)
  win = Window.new(height=10,width=60, y=45 , x=50 )
  win.box(?|, ?-)
  win.setpos(1,1)
  message_list.each_with_index do |message,i|
    win.setpos(i, 1)
    win.addstr(message + "\n")
  end
  win.refresh
  sleep 0.5
  win.close
end

def create_receive_process
  q = Queue.new
  Thread.start do
    server = TCPServer.new(10006)
    begin
      while true
        client = server.accept
        message = client.gets
        next if message == nil
        message = message.chomp
        message = JSON.parse(message)
        client.puts 'ok'
        q.push(message)
        client.close
      end
    rescue
    ensure
      client.close
    end
  end
  return q
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
  init_screen
  #stdscr.keypad true
  chara = Character.new(1,1)
  client_queue = create_wait_client_event_process
  #server_queue = create_receive_process
  server_queue = Queue.new
  server = TCPServer.new(10006)
  loop do
    #puts 'here'
    sleep 1
    Thread.start do
      #puts 'accept1'
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
    if server_queue.empty? == false
      #1puts 'sever data get!!!'
      message = server_queue.pop
      if message.instance_of?(Hash) && message['cmd'] == 'update_all_user_position'
        #puts message['params']
        write_screen(message['params'])
        write_sub(chara.get_message)
      else
        #puts message.to_s
        #sleep 2
        #abort
      end
    elsif client_queue.empty? == false
      key = client_queue.pop
      case key
      when Curses::Key::RIGHT
        chara.move(1,0)
      when Curses::Key::LEFT
        chara.move(-1,0)
      when Curses::Key::UP
        chara.move(0,-1)
      when Curses::Key::DOWN
        chara.move(0,1)
      else
        abort
        close_screen
      end
    end
    sleep 0.1
  end
ensure
  #close_screen
end
