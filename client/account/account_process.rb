## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

require 'require_all'
#gem 'require_all'
require_all './account/actions/'

class AccountProcess < BaseProcess
  NEW_GAME = 0
  CONTINUE = 1
  def initialize(tcp_client)
    @tcp_client = tcp_client
    @current_mode = :login_form
    @client_event = nil
    @login_status = 0
    @actions = [:login_form, [:create_user,:input_user_id], :select_job]
    @action_results = {}
  end
  def get_info
    {:user_id => 1, :level => 1, :status => {} }
  end
end
