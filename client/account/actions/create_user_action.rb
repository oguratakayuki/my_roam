## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class CreateUserAction < BaseAction
  attr_reader :name
  def initialize(queue)
    @name = :create_user
    @client_queue = queue
    @results = {}
    @view = CreateUserView.new
  end
  def execute
    while true
      event_result = nil
      return if @action_end
      @view.display({:form_name => :create_user})
      sleep 0.2
      unless @client_queue.empty?
        key = @client_queue.deq
        case key
        when Curses::Key::UP
          @view.move_element(:forth)
        when Curses::Key::DOWN
          @view.move_element(:back)
        when 9 # tab
          @view.move_element(:forth)
        when 10 #enter key
          #@results[:next_action_id] = cursor
          event_result = @view.key_event(key)
          #break
        when ' '
          event_result = @view.key_event(key)
          #break
        else
          #DevLog.get_instance.write "you push #{key.to_s}"
          event_result = @view.key_event(key)
          #abort 'unknow key'
          #next
          #continue
        end
        if event_result
          evaluate_event_result(event_result)
        end
      end
    end
  end
  def evaluate_event_result(event_result)
    if event_result.key?(:move_next)
      @action_end = true
      @results[:next_action_id] = event_result[:move_next_action_id]
    end
  end

end


