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
    @action_end = false
  end
  def execute
    while true
      event_result = nil
      if @action_end
        sleep 3
        abort
        return
      end
      @view.debugger_action
      @view.display({:form_name => :create_user})
      sleep 0.2
      unless @client_queue.empty?
        key = @client_queue.deq
        event_result = send_event(key)
        if event_result
          evaluate_event_result(event_result)
        end
      end
    end
  end
  def evaluate_event_result(event_result)
    if event_result[:action_info].key?(:move_next)
      @action_end = true
      @results[:login_type] = :new
      @results[:user_name] = event_result[:user_name]
      @results[:password] = event_result[:password]
    end
  end

end


