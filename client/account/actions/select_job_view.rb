## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

class SelectJobView < BaseView
  def set_form_name
    @form_name = :select_job
  end
  def load_setting
    @main_setting = YAML.load_file('account/actions/settings.yml')[:main_frame]
    @forms_setting = YAML.load_file('account/actions/settings.yml')[:forms]
  end

end
