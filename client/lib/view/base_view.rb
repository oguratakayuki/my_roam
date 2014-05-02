class BaseView
  def initialize
    @main_setting = YAML.load_file('account/actions/settings.yml')[:main_frame]
    @forms_setting = YAML.load_file('account/actions/settings.yml')[:forms]
    @logger = Logger.new('./log/base_view_log')
    @logger.level = Logger::WARN
    @elements = []
    @selected_element_id = 1
    @max_element_id = 0
    set_form_name
    create_elements
    #@elements.each do |element|
    #  @logger.warn element.to_s
    #end
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
    current_element.key_event(key)
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
  def write_input_element(h, w, x, y, write_str, win)
    win.setpos(y, x)
    up_down_str = '-'*w
    win.addstr(up_down_str)
    win.setpos(y+1, x)
    win.addstr('|')
    win.setpos(y+1, x+2)
    win.addstr(write_str)
    win.setpos(y+1, x+w)
    win.addstr('|')
    win.setpos(y+2, x)
    win.addstr(up_down_str)
  end
end


