## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
class BaseElement
  attr_accessor :attributes, :element_id, :value
  def to_s
    "element_id:#{@element_id}, h:#{@h},w:#{@w},x:#{@x},y:#{@y},type:#{self.class.to_s},title:#{@title}"
  end

  def key_event(key)
    #puts "you push #{key}"
    create_push_button_info if [' ',10].include?(key)
  end
  def set_selected(bool)
    @selected = bool
  end
  def key
    @attributes[:key].to_sym if @attributes.key?(:key)
  end

end

class TestElement < BaseElement
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @selected = false
    @text = ''
    @value = nil
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
    win.addstr(up_down_str)
  end
  def text_set(str)
    @text = str
  end
end


class HiddenElement < BaseElement
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @selected = false
    @text = ''
    @value = @attributes[:value]
  end
  def draw(win)
  end

end



class InputElement < BaseElement
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @selected = false
    @value = ''
  end
  def draw(win)
    win.setpos(@y, @x)
    up_down_str = '-'*@w
    win.addstr(up_down_str)
    win.setpos(@y+1, @x)
    win.addstr('|')
    win.setpos(@y+1, @x+2)
    win.addstr(@selected ? @attributes[:selected_title] : @title)
    win.setpos(@y+1, @x+@w)
    win.addstr('|')
    win.setpos(@y+2, @x)
    win.addstr('|')
    win.setpos(@y+2, @x+2)
    win.addstr(@value)
    win.setpos(@y+2, @x+@w)
    win.addstr('|')
    win.setpos(@y+3, @x)
    win.addstr('|')
    win.setpos(@y+3, @x+@w)
    win.addstr('|')
    win.setpos(@y+4, @x)
    win.addstr(up_down_str)
  end
  def key_event(key)
    #if key == '127'
    if key == 263
      temp = @value.split('')
      temp.pop
      @value = temp.join
    else
      @value << key.to_s
    end
    nil
  end
end

class ButtonElement < BaseElement
  attr_accessor :attributes, :element_id, :value, :end_call
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @text = ''
    @selected = false
    @value = nil
    @end_call = false
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
    win.addstr(up_down_str)
  end
  def key_event(key)
    if [" ",10].include?(key)
      @value = true
      @end_call = true
    end
  end
end

class RadioElement < BaseElement
  attr_accessor :attributes, :element_id, :value, :end_call, :buttons
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @text = ''
    @selected = false
    @end_call = false
    @buttons = {}
    setup_buttons
    @value = selected_button
  end
  def setup_buttons
    @attributes[:buttons].each do |button|
      @buttons[button.first] = button[1]
    end
    @cursor = @buttons.to_a.dup
  end
  def selected_button
    @buttons[@cursor.first.first]
  end
  def next_button
    @cursor.rotate!(1)
  end
  def back_button
    @cursor.rotate!(-1)
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
    win.addstr('|')
    win.setpos(@y+2, @x+1)

    @buttons.each do |k,v|
      if v == selected_button
        win.addstr("[x] #{k}  ")
      else
        win.addstr("[ ] #{k}  ")
      end
    end
    win.setpos(@y+2, @x+@w)
    win.addstr('|')
    win.setpos(@y+3, @x)
    win.addstr(up_down_str)
  end
  def key_event(key)
    if Curses::Key::RIGHT == key
      next_button
    else Curses::Key::LEFT == key
      back_button
    end
    @value = selected_button
  end
end








class WindowElement < BaseElement
  attr_accessor :attributes, :element_id, :value, :end_call, :buttons
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @text = ''
    @selected = false
    @end_call = false
    #setup_buttons
    @field_data = nil
  end
  def update_field_data(field_data)
    @field_data = field_data
  end
  def draw(win)
    win.setpos(@y, @x)
    up_down_str = '-'*@w
    win.addstr(up_down_str)
    for height in @y..(@y+@h) do
      win.setpos(height, @x)
      win.addstr('|')
      win.setpos(height, @x+@w)
      win.addstr('|')
    end
    win.setpos(@y + @h, @x)
    win.addstr(up_down_str)

    @field_data.each do |user|
      win.setpos( @y + user['y'], @x + user['x'])
      if user['type'] == 'enemy'
        win.addstr('E')
      else
        win.addstr(user['user_id'].to_s)
      end
    end if @field_data.is_a?(Array)

  end
  def key_event(key)
    #if Curses::Key::RIGHT == key
    #  next_button
    #else Curses::Key::LEFT == key
    #  back_button
    #end
    #@value = selected_button
  end
end


class ListElement < BaseElement
  attr_accessor :attributes, :element_id, :value, :end_call, :buttons
  def initialize(element_id, h, w, x, y, title, attributes)
    @element_id, @h, @w, @x, @y, @title, @attributes =  element_id, h, w, x, y, title, attributes
    @text = ''
    @selected = false
    @end_call = false
    #setup_buttons
    @field_data = nil
  end
  def update_list_data(list_data)
    @list_data = list_data
  end
  def draw(win)
    win.setpos(@y, @x)
    up_down_str = '-'*@w
    win.addstr(up_down_str)
    for height in @y..(@y+@h) do
      win.setpos(height, @x)
      win.addstr('|')
      win.setpos(height, @x+@w)
      win.addstr('|')
    end
    win.setpos(@y + @h, @x)
    win.addstr(up_down_str)

    @list_data.each_with_index do |data,i|
      win.setpos( (@y + i + 1), (@x + 1))
      win.addstr(data)
    end if @list_data.is_a?(Array)
  end

end








