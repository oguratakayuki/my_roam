## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

class ProcessAction
  attr_reader :action_results
end

class AccountProcessAction < ProcessAction
  NEW_GAME = 0
  CONTINUE = 1
  def initialize(tcp_client)
    @tcp_client = tcp_client
    @settings = YAML.load_file('processes.yml')
    @current_mode = :login_form
    @client_event = nil
    @login_status = 0
    @actions = [:login_form,[:create_user,:input_user_id]]
    @action_results = {}
  end
  def set_client_queue(client_queue)
    @client_queue = client_queue
  end
  def start
    @actions.each do |current_action|
      if current_action.instance_of?(Array)
        #前回のアクションに分岐がある場合
        prev_action_result = get_prev_action_result(current_action)
        dispatch_event(current_action[prev_action_result])
      else
        dispatch_event(current_action)
      end
    end
  end
  def dispatch_event(action_name)
    if action_name == :login_form
      cursor = 0
      while true
        display_form(key = :login_form, option = {:cursor => cursor})
        sleep 0.2
        unless @client_queue.empty?
          key = @client_queue.deq
          case key
          when Curses::Key::UP
            cursor == 0 ? cursor = 1 : cursor = 0
          when Curses::Key::DOWN
            cursor == 0 ? cursor = 1 : cursor = 0
          when 10 #enter key
            set_action_result(action_name, cursor)
            break
          else
            abort 'unknow key'
            continue
          end
        end
      end
    elsif action_name == :create_user
      abort 'we now here'
    end
    sleep 1
    Curses::close_screen
  end
  def set_action_result(action_name, action_result)
    @action_results[action_name] = action_result
  end
  def get_prev_action_result(action_name)
    prev_action_name = @actions[@actions.index(action_name) -1]
    @action_results[prev_action_name]
  end

  def display_form(key, option)
    Curses::init_screen
    stdscr.keypad true
    form_setting = @settings[key]
    w,h,x,y = form_setting[:positions].values_at(:width, :height, :x, :y)
    win = Window.new(w,h,x,y)
    win.box(?|, ?-)

    form_setting[:elements].each do |menue|
      win.setpos(menue[:y], menue[:x])
      write_str = option[:cursor] == menue[:id] ? menue[:selected_title] : menue[:title]
      win.addstr(write_str)
    end
    win.refresh
    #sleep 3
    #Curses::refresh
  end

  def get_info
    {:user_id => 1, :level => 1, :status => {} }
  end
end
