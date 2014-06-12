## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class SelectJobAction < BaseAction
  attr_reader :name
  def initialize(process_results)
    @process_results = process_results
    @name = :select_job
    @results = {}
    @view = SelectJobView.new
    @action_end = false
    @logger = Logger.new('./log/select_job_action_log')
    @logger.level = Logger::WARN
  end
  #ここはbaseに持っていけそう
  def execute
    while true
      event_result = nil
      if @view.is_end?
        @view.close_view
        return
      end
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
  def evaluate_event_result(elements_info)
    @logger.error "process_results = #{@process_results.to_s}"
    @logger.error "elements_info = #{elements_info.to_s}"
    user_id = @process_results[:create_user][:user_id]
    @results[:job_id] = elements_info[:job_id]
    ApplicationContext.instance.tcp_client.user_change_job(user_id, elements_info[:job_id])
  end
end


