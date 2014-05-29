## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class CreateUserAction < BaseAction
  attr_reader :name
  def initialize(queue, tcp_client)
    @tcp_client = tcp_client
    @name = :create_user
    @client_queue = queue
    @results = {}
    @view = CreateUserView.new
    @action_end = false
    @logger = Logger.new('./log/create_user_log')
    @logger.level = Logger::WARN
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
      exit
      abort
      user_id = @tcp_client.user_registration(event_result[:user_name], event_result[:password])
    else
      @logger.error "user name error"
    end

    @logger.error "!!!!!!!!!!return=#{ret.to_s}"
    @action_end = true
    @results[:login_type] = :new
    @results[:user_name] = event_result[:user_name]
    @results[:password] = event_result[:password]
    @logger.error "!!!!!!!!!!return=#{@results.to_s}"
  end
end


