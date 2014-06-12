## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './login_form_view.rb'
require 'yaml'

class PlayGameAction < BaseAction
  attr_reader :name
  def initialize(process_results=nil)
    @name = :play_game
    @results = {}
    @view = PlayGameView.new
    @action_end = false
    @logger = Logger.new('./log/play_game_action_log')
    @logger.level = Logger::WARN
  end
  #ここはbaseに持っていけそう
  def execute
    user_info = ApplicationContext.instance.user_info
    ApplicationContext.instance.tcp_client.user_login(user_info[:user_id])
    position = ApplicationContext.instance.tcp_client.init_user_position(user_info[:user_id])
    chara = Character.new(user_info[:user_id], position['x'], position['y'])

    sub_message_list = ["user_id:#{user_info[:user_id]}", "job:#{Job::JobList[1]}", "user_name:#{user_info[:user_name]}","LEVEL:1","HP:100","STRENGTH:10","MP:20"]
    while true
      event_result = nil
      if @view.is_end?
        @view.close_view
        return
      end
      @view.display
      sleep 0.03
      if ApplicationContext.instance.server_queue.empty? == false
        message = ApplicationContext.instance.server_queue.pop
        if message.instance_of?(Hash) && message['cmd'] == 'update_all_user_position'
          #エフェクトも含む
          @logger.error "move message #{message['params'].to_s}}"
          updated_user_position_list = message['params']
          @view.update_main(updated_user_position_list)
          #@view.update_sub(sub_message_list)
          @view.update_sub(chara.get_message)
          @view.display
        else
        end
      end
      if ApplicationContext.instance.client_queue.empty? == false
        key = ApplicationContext.instance.client_queue.deq
        #send_event(key)
        case key
        when Curses::Key::RIGHT
          ApplicationContext.instance.tcp_client.move(user_info[:user_id], chara.x + 1 , chara.y) and chara.move(1,0)
        when Curses::Key::LEFT
          ApplicationContext.instance.tcp_client.move(user_info[:user_id], chara.x - 1 , chara.y) and chara.move(-1,0)
        when Curses::Key::UP
          ApplicationContext.instance.tcp_client.move(user_info[:user_id], chara.x, chara.y - 1) and chara.move(0, -1)
        when Curses::Key::DOWN
          ApplicationContext.instance.tcp_client.move(user_info[:user_id], chara.x, chara.y + 1) and chara.move(0, 1)
        when 's'
          #後ろ攻撃#判定、effectはサーバーからうけとる
          ApplicationContext.instance.tcp_client.attack(user_info[:user_id], chara.x, chara.y, 'left') #and chara.move(0, 1)
        when 'e'
          #上段攻撃
          ApplicationContext.instance.tcp_client.attack(user_info[:user_id], chara.x, chara.y, 'up') #and chara.move(0, 1)
        when 'f'
          #前方攻撃
          ApplicationContext.instance.tcp_client.attack(user_info[:user_id], chara.x, chara.y, 'right') #and chara.move(0, 1)
        when 'd'
          #下段攻撃
          ApplicationContext.instance.tcp_client.attack(user_info[:user_id], chara.x, chara.y, 'down') #and chara.move(0, 1)
        else
          abort
          close_screen
        end

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


