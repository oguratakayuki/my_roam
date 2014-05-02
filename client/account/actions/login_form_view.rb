## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
#require './process.rb'
require 'yaml'


class LoginFormView < BaseView
  def set_form_name
    @form_name = :login
  end
end
