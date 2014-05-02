## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
require 'yaml'
class BaseAction
  def has_interrupt_next_action?
    false
  end
  def interrupt_next_action_name
  end
  def results
    @results
  end
  def result_by_key(key)
    @results[key]
  end
end


