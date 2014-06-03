class Display
  def initialize(window_info)

    @window_position_x = window_info['main_position_x']
    @window_position_y = window_info['main_position_y']
    @window_width = window_info['main_width']
    @window_height = window_info['main_height']
    @sub_window_position_x = window_info['sub_position_x']
    @sub_window_position_y = window_info['sub_position_y']
    @sub_window_width = window_info['sub_width']
    @sub_window_height = window_info['sub_height']

    @side_window_position_x = window_info['side_position_x']
    @side_window_position_y = window_info['side_position_y']
    @side_window_width = window_info['side_width']
    @side_window_height = window_info['side_height']


    #@window_position_x = 50
    #@window_position_y = 15
    #@window_width = 60
    #@window_height = 30
    #@sub_window_position_x = 50
    #@sub_window_position_y = 45
    #@sub_window_width = 60
    #@sub_window_height = 10
    init_screen
  end
  def initialize_view
    #GameTcpClient.new.get_first_view
  end
  def write(user_list, message_list, sub_message_list)
    init_screen
    write_main(user_list)
    write_sub(message_list)
    write_side(sub_message_list)
  end
  def is_movable?(x,y)
  end
  def write_main(user_list)
    #[{"user_id"=>1, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>2, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>3, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}]
    Curses.init_screen
    stdscr.keypad true
    win = Window.new(@window_height,@window_width, @window_position_y , @window_position_x )
    win.box(?|, ?-)
    user_list.each do |user|
      win.setpos(user['y'], user['x'])
      if user['type'] == 'enemy'
        win.addstr('E')
      else
        win.addstr(user['user_id'].to_s)
      end
    end
    win.refresh
sleep 0.02
    win.close
  end
  def write_sub(message_list)
    win = Window.new(@sub_window_height, @sub_window_width, @sub_window_position_y , @sub_window_position_x )
    win.box(?|, ?-)
    win.setpos(1,1)
    message_list.each_with_index do |message,i|
      win.setpos(i, 1)
      win.addstr(message + "\n")
    end
    win.refresh
    win.close
  end
  def write_side(message_list)
    win = Window.new(@side_window_height, @side_window_width, @side_window_position_y , @side_window_position_x )
    win.box(?|, ?-)
    win.setpos(1,1)
    message_list.each_with_index do |message,i|
      win.setpos(i, 1)
      win.addstr(message + "\n")
    end
    win.refresh
    win.close
  end


end


