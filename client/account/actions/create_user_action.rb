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
    cursor = 0
    while true
      @view.display({:form_name => :create_user, :cursor => cursor})
      sleep 0.2
      unless @client_queue.empty?
        key = @client_queue.deq
        case key
        when Curses::Key::UP
          cursor == 0 ? cursor = 1 : cursor = 0
        when Curses::Key::DOWN
          cursor == 0 ? cursor = 1 : cursor = 0
        when 10 #enter key
          @results[:next_action_id] = cursor
          break
        else
          abort 'unknow key'
          continue
        end
      end
    end
    if @results[:cursor] == 1
    end
  end

end


