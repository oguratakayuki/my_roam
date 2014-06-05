## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class LoginFormAction < BaseAction
  attr_reader :name
  def initialize(process_results)
    @process_results = process_results
    @name = :login_form
    @results = {}
    @view = LoginFormView.new
    @action_end = false
    @logger = Logger.new('./log/login_form_action_log')
    @logger.level = Logger::WARN
  end
  #ここはbaseに持っていけそう
  def execute
    while true
      event_result = nil
      return if @view.is_end?
      @view.display
      sleep 0.2
      unless ApplicationContext.instance.client_queue.empty?
        key = ApplicationContext.instance.client_queue.deq
        send_event(key)
        if @view.is_end?
          evaluate_event_result(@view.elements_info)
        end
      end
    end
  end
  def evaluate_event_result(event_result)
    @logger.error event_result.to_s
    if event_result[:signup_button]
      @results[:next_action_id] = 0
    elsif event_result[:signup_button]
      @results[:next_action_id] = 1
    else
      abort
      exit
    end
  end
end


