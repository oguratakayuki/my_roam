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
#puts "here ok #{@id}"
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
  #puts 'start write screen'
  init_screen
  stdscr.keypad true
  win = Window.new(height=30,width=60, y=15 , x=50 )
  win.box(?|, ?-)
  user_list.each do |user|
    puts "user_id = #{user['user_id']}"
    win.setpos(user['y'], user['x'])
    win.addstr(user['user_id'])
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
  fork do
    #puts 'before server start'
    logger = Logger.new('./log/hello.txt')
    logger.level = Logger::WARN
    server = TCPServer.new(10006)
    #puts 'after server start'
    loop do
      client = server.accept
      fork do    # 別プロセスで起動
        begin
          loop do
            message = client.gets
            next if message == nil
            message = message.chomp
            message = JSON.parse(message)
            client.puts 'ok'
            q.push(message)
            #client.close
            #puts "recieve message!!!#{message.to_s}"
    #logger.error  "recieve message!!!#{message.to_s}"
    #{"cmd"=>"update_all_user_position", "params"=>[{"user_id"=>1, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>2, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>3, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}]}
            #refresh
          end
        rescue
        ensure
          client.close
        end
      end
    end
  end
  return q
end

def create_wait_client_event_process
  q = Queue.new
  fork do
    while(key = Curses.getch)
      q.push(key)
      #case key
      #when Curses::Key::RIGHT
      #  chara.move(1,0)
      #when Curses::Key::LEFT
      #  chara.move(-1,0)
      #when Curses::Key::UP
      #  chara.move(0,-1)
      #when Curses::Key::DOWN
      #  chara.move(0,1)
      #else
      #  #puts key
      #  abort
      #  close_screen
      #end
    end
  end
  return q
end


begin
  #for test start
  init_screen
  stdscr.keypad true
  chara = Character.new(1,1)
  #chara.move(1,0)
  #write_screen(chara)
  server_queue = create_receive_process
  client_queue = create_wait_client_event_process
  loop do
    if server_queue.empty? == false
      message = server_queue.pop
      if message['cmd'] == 'update_all_user_position'
        write_screen(message['params'])
        write_sub(chara.get_message)
      end
    elsif key = client_queue.pop
      #key = client_queue.pop
abort "key is accepted!!!#{key}"
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
        #puts key
        abort
        close_screen
      end
    end
    sleep 1
    puts 'HI'
  end
ensure
  close_screen
end
