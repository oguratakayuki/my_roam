require "curses"
 
Curses.init_screen
Curses.stdscr.keypad true
 
begin
  case Curses.getch
  when Curses::Key::RIGHT
    Curses.addstr("right")
  when Curses::Key::LEFT
    Curses.addstr("left")
  when Curses::Key::UP
    Curses.addstr("up")
  when Curses::Key::DOWN
    Curses.addstr("down")
  end
   
  Curses.getch
ensure
  Curses.close_screen
end
