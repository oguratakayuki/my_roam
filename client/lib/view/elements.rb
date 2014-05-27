## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
class BaseElement
  attr_accessor :attributes, :element_id, :object_key, :object_value
  def to_s
    "element_id:#{@element_id}, h:#{@h},w:#{@w},x:#{@x},y:#{@y},type:#{self.class.to_s},title:#{@title}"
  end

  def key_event(key)
    #puts "you push #{key}"
    create_push_button_info if [' ',10].include?(key)
  end
  def create_push_button_info
    {
      :pushed_element_id => @element_id,
      :pushed_element_title => @title,
      :pushed_element_action_end_info => @attributes[:action_end_info],
    }
  end

  def set_selected(bool)
    @selected = bool
  end
  def element_key
    #@attributes[:object_name].to_sym if @attributes.key?(:object_name)
    @attributes[:object_name].to_sym
  end
  def element_value
    #@object_value if defined?(@object_value)
    @object_value
  end
end

class TestElement < BaseElement
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @selected = false
    @text = ''
    @object_value = nil
  end
  def draw(win)
    win.setpos(@y, @x)
    up_down_str = '-'*@w
    win.addstr(up_down_str)
    win.setpos(@y+1, @x)
    win.addstr('|')
    win.setpos(@y+1, @x+2)
    win.addstr(@text)
    win.setpos(@y+1, @x+@w)
    win.addstr('|')
    win.setpos(@y+2, @x)
    win.addstr(@up_down_str)
  end
  def text_set(str)
    @text = str
  end
end



class InputElement < BaseElement
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @selected = false
    @object_value = ''
  end
  def draw(win)
    win.setpos(@y, @x)
    up_down_str = '-'*@w
    win.addstr(up_down_str)
    win.setpos(@y+1, @x)
    win.addstr('|')
    win.setpos(@y+1, @x+2)
    win.addstr(@selected ? @attributes[:selected_title] : @title)

    win.setpos(@y+2, @x+2)
    win.addstr(@object_value)

    win.setpos(@y+3, @x+@w)
    win.addstr('|')

    win.setpos(@y+4, @x)
    win.addstr(@up_down_str)
  end
  def key_event(key)
    #if key == '127'
    if key == 263
      temp = @object_value.split('')
      temp.pop
      @object_value = temp.join
    else
      @object_value << key.to_s
    end
    nil
  end


end
class ButtonElement < BaseElement
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @text = ''
    @selected = false
    @object_value = nil
  end
  def draw(win)
    @text = @selected ? @attributes[:selected_title] : @title
    win.setpos(@y, @x)
    up_down_str = '-'*@w
    win.addstr(up_down_str)
    win.setpos(@y+1, @x)
    win.addstr('|')
    win.setpos(@y+1, @x+2)
    win.addstr(@text)
    win.setpos(@y+1, @x+@w)
    win.addstr('|')
    win.setpos(@y+2, @x)
    win.addstr(@up_down_str)
  end
  def key_event(key)
    if [" ",10].include?(key)
      create_push_button_info
    end
  end
end
