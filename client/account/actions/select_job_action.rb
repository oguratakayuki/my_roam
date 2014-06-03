## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class SelectJobAction < BaseAction
  attr_reader :name
  def initialize(queue, tcp_client, process_results)
    @process_results = process_results
    @tcp_client = tcp_client
    @name = :select_job
    @client_queue = queue
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
      unless @client_queue.empty?
        key = @client_queue.deq
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
    @tcp_client.user_update(user_id, {:job_id => elements_info[:job_id]})
  end
end


