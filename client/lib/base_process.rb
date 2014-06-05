## -*- coding: utf-8 -*-
class BaseProcess
  attr_reader :action_results
  def camelize(name)
    name.split(/[^a-z0-9]/i).map{|w| w.capitalize}.join
  end
  def get_action(key)
    name = camelize(key.to_s) + 'Action'
    Kernel.const_get(name)
  end
  def set_action_result(action_name, action_result)
    @action_results[action_name] = action_result
  end
  def get_prev_action_result(action_name)
    prev_action_name = @actions[@actions.index(action_name) -1]
    @action_results[prev_action_name]
  end
  def set_client_queue(client_queue)
    @client_queue = client_queue
  end
  def start
    @actions.each do |current_action_name|
      if current_action_name.instance_of?(Array)
        #前回のアクションに分岐がある場合
        prev_action_result = get_prev_action_result(current_action_name)
        dispatch_event(current_action_name[prev_action_result[:next_action_id]])
      else
        dispatch_event(current_action_name)
      end
    end
  end
  def results
    @action_results
  end
  def dispatch_event(action_name)
    #action = get_action(action_name).new(@client_queue, @action_results)
    action = get_action(action_name).new(@action_results)
    action.execute
    set_action_result(action_name, action.results)
    if action.has_interrupt_next_action?
      i_action = action.interrupt_next_action_name
      dispatch_event(i_action)
    end
    #abort 'yeah' + action.results.to_s
    #sleep 1
    #Curses::close_screen
  end
end


