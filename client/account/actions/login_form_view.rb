## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

class InputElement
  def initialize(element_id, h, w, x, y, title)
    @element_id, @h, @w, @x, @y, @title =  element_id, h, w, x, y, title
    @is_selected = false
  end
  def write_out_screen(window)
  end
  def accept_action(key_event)
  end
end
class BaseView
  def initialize
    @main_setting = YAML.load_file('account/actions/settings.yml')[:main_frame]
    @forms_setting = YAML.load_file('account/actions/settings.yml')[:forms]
    @logger = Logger.new('./log/base_view_log')
    @logger.level = Logger::WARN

  end
  def display(option)
    Curses::init_screen
    stdscr.keypad true
    display_main
    form_setting = @forms_setting[option[:form_name]]
    h,w,x,y = form_setting[:positions].values_at(:height, :width, :x, :y)
    win = Window.new(h,w,x,y)
    win.box(?|, ?-)

    form_setting[:elements].each do |element|
      if element[:type] == :input
        w,x,y = element.values_at(:width, :x, :y)
        h = 1
        write_str = option[:cursor] == element[:id] ? element[:selected_title] : element[:title]
        write_input_element(h, w, x, y, write_str, win)
      else
        win.setpos(element[:y], element[:x])
        write_str = option[:cursor] == element[:id] ? element[:selected_title] : element[:title]
        win.addstr(write_str)
      end
    end
    win.refresh
    #sleep 3
    #Curses::refresh
  end
  def display_main
    h,w,x,y = @main_setting[:positions].values_at(:height, :width, :x, :y)
    win = Window.new(h,w,x,y)
    win.box(?|, ?-)
    win.refresh
  end
  def write_input_element(h, w, x, y, write_str, win)
    win.setpos(y, x)
    up_down_str = '-'*w
    win.addstr(up_down_str)
    win.setpos(y+1, x)
    win.addstr('|')
    win.setpos(y+1, x+2)
    win.addstr(write_str)
    win.setpos(y+1, x+w)
    win.addstr('|')
    win.setpos(y+2, x)
    win.addstr(up_down_str)
  end
end

class LoginFormView < BaseView
end
