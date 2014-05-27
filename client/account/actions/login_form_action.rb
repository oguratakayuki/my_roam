## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class LoginFormAction < BaseAction
  attr_reader :name
  def initialize(queue)
    @name = :login_form
    @client_queue = queue
    @results = {}
    @view = LoginFormView.new
    @action_end = false
  end
  def execute
    while true
      event_result = nil
      return if @action_end
      @view.display({:form_name => :login})
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
    if event_result[:pushed_element_action_end_info].key?(:move_next)
      @action_end = true
      @results[:next_action_id] = event_result[:pushed_element_action_end_info][:move_next_action_id]
    end
  end

end


