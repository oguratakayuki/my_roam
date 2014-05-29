## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
require 'yaml'
class BaseAction
  def has_interrupt_next_action?
    false
  end
  def interrupt_next_action_name
  end
  def results
    @results
  end
  def result_by_key(key)
    @results[key]
  end

  def send_event(key)
    case key
    when Curses::Key::UP
      @view.move_element(:back, :is_selectable)
    when Curses::Key::DOWN
      @view.move_element(:forth, :is_selectable)
    when 9 # tab
      @view.move_element(:forth, :is_selectable)
    when 10 #enter key
      @view.key_event(key)
    when ' '
      @view.key_event(key)
    else
      @view.key_event(key)
    end
  end
end


