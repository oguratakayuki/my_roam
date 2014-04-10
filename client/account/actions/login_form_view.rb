## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

class BaseElement
  def to_s
    "element_id:#{@element_id}, h:#{@h},w:#{@w},x:#{@x},y:#{@y},type:#{self.class.to_s}"
  end
end
class InputElement < BaseElement
  def initialize(element_id, h, w, x, y)
    @element_id, @h, @w, @x, @y, @title =  element_id, h, w, x, y, title
    @is_selected = false
  end
  def write_out_screen(window)
  end
  def accept_action(key_event)
  end
end
class ButtonElement < BaseElement
  def initialize(element_id, h, w, x, y)
    @element_id, @h, @w, @x, @y, @title =  element_id, h, w, x, y
  end
end

class BaseView
  def initialize
    @main_setting = YAML.load_file('account/actions/settings.yml')[:main_frame]
    @forms_setting = YAML.load_file('account/actions/settings.yml')[:forms]
    @logger = Logger.new('./log/base_view_log')
    @logger.level = Logger::WARN
    @elements = []
    @selected_element_id = 1
    @max_element_id = 0
    set_form_name
    create_elements
    @elements.each do |element|
      @logger.warn element.to_s
    end
  end
  def setup_form
  end
  def create_elements
    #ここでelementsごとのオブジェクトを生成しオブジェクトごとにkey eventを定義する
    elements_settings = @forms_setting[@form_name][:elements]
    elements_settings.each do |element_setting|
      element_name = element_setting[:type].to_s.capitalize + 'Element'
      id,h,w,x,y = element_setting.values_at(:id, :h, :w, :x, :y)
      @elements << Kernel.const_get(element_name).new(id,h,w,x,y)
    end
    @max_element_id = @elements.count
  end
  def key_event(key)
  end
  def move_cursor_next
    @selected_element_id = @selected_element_id + 1 == @max_element_id ? @selected_element_id + 1 : @selected_element_id  = 0
  end

  def move_cursor_prev
    @selected_element_id = @selected_element_id + 1
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
  def set_form_name
    @form_name = :login
  end
end
