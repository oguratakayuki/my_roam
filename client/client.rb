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
require './game/game_process.rb'
require './lib/dev_log.rb'
require './lib/game_tcp_client.rb'
require './lib/application_context.rb'
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
  def started?
    @queue == nil ? false : true
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


begin
  logger = Logger.new('./log/tcp_server_log.txt')
  logger.level = Logger::WARN
  tcp_client = GameTcpClient.new
  ApplicationContext.instance.tcp_client = tcp_client
  account_process = AccountProcess.new
  account_process.start
  ApplicationContext.instance.set_user_info(account_process.action_results)

  game_process = GameProcess.new
  game_process.start
  #sub_message_list = ["user_id:#{user_id}", "job:#{Job::JobList[1]}", "user_name:#{user_name}","LEVEL:1","HP:100","STRENGTH:10","MP:20"]

ensure
  #close_screen
end
