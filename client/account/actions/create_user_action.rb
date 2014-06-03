## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class CreateUserAction < BaseAction
  attr_reader :name
  def initialize(queue, tcp_client, process_results)
    @process_results = process_results
    @tcp_client = tcp_client
    @name = :create_user
    @client_queue = queue
    @results = {}
    @view = CreateUserView.new
    @action_end = false
    @logger = Logger.new('./log/create_user_log')
    @logger.level = Logger::WARN
  end
  #ここはbaseに持っていけそう
  def execute
    while true
      event_result = nil
      #if @action_end
      if @view.is_end?
        return
      end
      @view.debugger_action
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
    if @tcp_client.check_user_name(elements_info[:user_name])
      @logger.error "user name success"
      user_id = @tcp_client.user_registration(elements_info[:user_name], elements_info[:password])
      @logger.error "!!!!!!!!!!user_id=#{user_id.to_s}"
    else
      @logger.error "user name error"
    end

    @logger.error "!!!!!!!!!!return=#{user_id.to_s}"
    @action_end = true
    @results[:login_type] = :new
    @results[:user_id] = user_id
    @results[:user_name] = elements_info[:user_name]
    @results[:password] = elements_info[:password]
    @logger.error "!!!!!!!!!!return=#{@results.to_s}"
  end
end


