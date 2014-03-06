## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

class BaseView
  def initialize(key)
    @form_setting = YAML.load_file('account/actions/settings.yml')[key]
  end
  def display(option)
    Curses::init_screen
    stdscr.keypad true
    w,h,x,y = @form_setting[:positions].values_at(:width, :height, :x, :y)
    win = Window.new(w,h,x,y)
    win.box(?|, ?-)

    @form_setting[:elements].each do |menue|
      win.setpos(menue[:y], menue[:x])
      write_str = option[:cursor] == menue[:id] ? menue[:selected_title] : menue[:title]
      win.addstr(write_str)
    end
    win.refresh
    #sleep 3
    #Curses::refresh
  end
end

class LoginFormView < BaseView
end
