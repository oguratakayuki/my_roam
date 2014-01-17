class Display
  def initialize
    @window_position_x = 50
    @window_position_y = 15
    @window_width = 60
    @window_height = 30
    @sub_window_position_x = 50
    @sub_window_position_y = 45
    @sub_window_width = 60
    @sub_window_height = 10
    init_screen
  end
  def initialize_view
    #GameTcpClient.new.get_first_view
  end
  def write(user_list, message_list)
    init_screen
    write_main(user_list)
    write_sub(message_list)
  end
  def write_main(user_list)
    #[{"user_id"=>1, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>2, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}, {"user_id"=>3, "ip"=>"192.168.12.3", "x"=>2, "y"=>1}]
    Curses.init_screen
    stdscr.keypad true
    win = Window.new(@window_height,@window_width, @window_position_y , @window_position_x )
    win.box(?|, ?-)
    user_list.each do |user|
      win.setpos(user['y'], user['x'])
      win.addstr(user['user_id'].to_s)
    end
    win.refresh
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
end


