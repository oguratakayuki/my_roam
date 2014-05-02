## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'

class CreateUserView < BaseView
  def set_form_name
    @form_name = :create_user
  end
end
