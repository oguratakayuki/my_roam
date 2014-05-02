## -*- coding: utf-8 -*-
#!/usr/local/bin/ruby
class ElementsIterator
  def initialize(elements_settings)
    @elements = []
    elements_settings.each do |element_setting|
      element_name = element_setting[:type].to_s.capitalize + 'Element'
      id,h,w,x,y,title,attributes = element_setting.values_at(:id, :h, :w, :x, :y, :title, :attributes)
      @elements << Kernel.const_get(element_name).new(id,h,w,x,y, title, attributes)
    end
    @elements.sort!{|a,b| a.element_id <=> b.element_id }
    @current_element_id = 0
    @element_counts = @elements.count
    all(:is_selectable).first.set_selected(true)
  end
  def all(option=nil)
    if option
      @elements.delete_if{|t| t.attributes[option] == true }
    else
      @elements
    end
  end
  def key_event(key)
    current.key_event(key)
  end
  def current
    @elements[@current_element_id]
  end
  def move(direction=nil, option=nil)
    direction = :forth if direction == nil
    if option
      element_id = move_by_attribute(direction, option)
      @current_element_id = element_id if element_id != nil
    else
      __send__("move_#{direction}_one")
    end
    all.each{|t| t.selected_toggle}
  end
  def move_by_attribute(direction, option)
    if @elements.index{|t| t.__send__(option.to_s) == true}
      while true do
        __send__("move_#{direction}_one")
        break if current.__send__(option.to_s) == true
      end
    end
  end
  def move_forth_one
    if @current_element_id + 1 < @element_counts
      @current_element_id = @current_element_id += 1
    else
      @current_element_id = 0
    end
  end
  def move_back_one
    if @current_element_id - 1 >= 0
     @current_element_id = @current_element_id - 1
    else
      @current_element_id = @element_counts -1
    end
  end
  def move_up
    move_back
  end
  def move_down
    move_forth
  end
end


