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



class EffectObject
  def initialize(id,type,h,w,x,y,life_time)
  end
  def draw(win)
  end
end

class EffectObjectList
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
    #user_list=[{:user_id=>1, :ip=>nil, :x=>47, :y=>2, :type=>"enemy", :hp=>100}, {:user_id=>2, :ip=>"192.168.12.25", :x=>32, :y=>8, :type=>nil, :hp=>100}
    # [{"user_id"=>1, "ip"=>nil, "x"=>59, "y"=>17, "type"=>"enemy", "hp"=>100}, {"user_id"=>2,
    #これを
    #user_list=[{:type => user, :x=> 1, :y =>1, :effect => :attacked}, {:type => "effect", :effect_id => 1, :x => 1, :y => 1}...にする
    @field_data.each do |f_d|
      win.setpos( @y + f_d['y'], @x + f_d['x'])
      if ['enemy','user'].include?(f_d['type'])
        chara_string = user_type_to_chara(f_d['type'], f_d['user_id'])
        if f_d['attr'].key?('effect') && f_d['attr']['effect'] != nil
          Curses.start_color
          Curses.init_pair 1, Curses::COLOR_RED, Curses::COLOR_BLACK
          Curses.init_pair 2, Curses::COLOR_BLACK, Curses::COLOR_RED
          win.attron(Curses.color_pair(1))
          #win.attrset(Curses.color_pair(1))
          win.addstr("!"+ chara_string.to_s)
          win.attroff(Curses.color_pair(1))
        else
          win.addstr(chara_string.to_s)
        end
      elsif f_d['type'] == 'effect'
        if f_d['attr']['effect_type'] == 'attack_fail'
          case f_d['attr']['direction']
          when 'left'
            win.addstr("<")
          when 'up'
            win.addstr("^")
          when 'right'
            win.addstr(">")
          when 'down'
            win.addstr("l")
          end
        end
      end
    end if @field_data.is_a?(Array)

    def user_type_to_chara(type, user_id)
      case type
      when 'user'
        user_id
      when 'enemy'
        'E'
      end
    end

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
    @list_data = []
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








