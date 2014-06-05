## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

class PlayGameView < BaseView
  def set_form_name
    @form_name = :play_game
  end
  def load_setting
    @main_setting = YAML.load_file('game/actions/settings.yml')[:main_frame]
    @forms_setting = YAML.load_file('game/actions/settings.yml')[:forms]
  end

  def update_main(updated_user_position_list)
    @elements.find_by_key(:main_window).update_field_data(updated_user_position_list)
  end

  def update_sub(data)
    @elements.find_by_key(:sub_window).update_list_data(data)
  end


end
