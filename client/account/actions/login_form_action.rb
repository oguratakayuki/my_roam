## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
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
end

class LoginFormAction < BaseAction
  attr_reader :name
  def initialize(queue)
    @name = :login_form
    @client_queue = queue
    @results = {}
    @view = LoginFormView.new
  end
  def execute
    cursor = 0
    while true
      @view.display({:form_name => :login, :cursor => cursor})
      sleep 0.2
      unless @client_queue.empty?
        key = @client_queue.deq
        case key
        when Curses::Key::UP
          cursor == 0 ? cursor = 1 : cursor = 0
        when Curses::Key::DOWN
          cursor == 0 ? cursor = 1 : cursor = 0
        when 9 # tab
          cursor == 0 ? cursor = 1 : cursor = 0
        when 10 #enter key
          @results[:next_action_id] = cursor
          break
        else
          DevLog.get_instance.write "you push #{key.to_s}"
          @view.key_event(key)
          #abort 'unknow key'
          next
          #continue
        end
      end
    end
    if @results[:cursor] == 1
    end
  end

end


