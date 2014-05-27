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


    @logger = Logger.new('./log/element_iterator_log')
    @logger.level = Logger::WARN

  end
  def all(option=nil)
    if option
      @elements.select{|t| t.attributes.key?(option) && t.attributes[option] }
    else
      @elements
    end
  end
  def debugger_action
    str = "ce=#{@current_element_id.to_s}/ec=#{@element_counts.to_s}"
    all(:is_test).first.text_set(str)
  end


  def key_event(key)
    result = current.key_event(key)
    #使って無かった。base_viewでやっている
    if result.is_a?(Hash) && result.key?(:action_info)
      #終わり
      all.each do |t|
        result[t.element_key] = t.element_value if t.element_key
      end
      result
    else
      nil
    end

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
    all.each{|t| t.set_selected(false)}
    current.set_selected(true)
  end
  def move_by_attribute(direction, option)
    #if @elements.index{|t| t.__send__(option.to_s) == true}
    if @elements.index{|t| t.attributes[option] == 1}
      while true do
        __send__("move_#{direction}_one")
        break if current.attributes[option] == 1 
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


