## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

require 'require_all'
#gem 'require_all'
require_all './game/actions/'

class GameProcess < BaseProcess
  def initialize
    @login_status = 0
    @actions = [:play_game, :save_and_logout]
    @action_results = {}
  end
  def get_info
    {:user_id => 1, :level => 1, :status => {} }
  end
end
