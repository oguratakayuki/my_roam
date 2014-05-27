## -*- coding: utf-8 -*-
class BaseView
  def initialize
    load_setting
    @logger = Logger.new('./log/base_view_log')
    @logger.level = Logger::WARN
    @elements = nil
    @selected_element_id = 1
    @max_element_id = 0
    set_form_name
    create_elements
    #@elements.each do |element|
    #  @logger.warn element.to_s
    #end
  end
  def debugger_action
    @elements.debugger_action
  end

  def setup_form
  end
  def create_elements
    #ここでelementsごとのオブジェクトを生成しオブジェクトごとにkey eventを定義する
    @elements = ElementsIterator.new(@forms_setting[@form_name][:elements])
  end
  def current_element
    @elements.current
  end
  def move_element(direction=nil, option=nil)
    @elements.move(direction, option)
  end
  def key_event(key)
    #result = current_element.key_event(key)
    result = @elements.current.key_event(key)
    if result.is_a?(Hash) && result.key?(:pushed_element_action_end_info)
      #終わり
      @elements.all.each do |t|
        result[t.element_key] = t.element_value if t.element_key
      end
      result
    else
      nil
    end


  end

  def display(option)
    Curses::init_screen
    stdscr.keypad true
    display_main
    form_setting = @forms_setting[option[:form_name]]
    h,w,x,y = form_setting[:positions].values_at(:height, :width, :x, :y)
    win = Window.new(h,w,x,y)
    win.box(?|, ?-)

    @elements.all.each do |element|
      element.draw(win)
    end
    win.refresh
    #sleep 3
    #Curses::refresh
  end
  def display_main
    h,w,x,y = @main_setting[:positions].values_at(:height, :width, :x, :y)
    win = Window.new(h,w,x,y)
    win.box(?|, ?-)
    win.refresh
  end
end


