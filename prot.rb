class Game
  def initialize
    @width = 20
    @height = 10
    init_user_position_list
  end
  def init_user_position_list
    @user_position = Array.new(@height).map{Array.new(@width, nil)}
    @user_position[3][5] = 'A'
  end
  def draw_screen
    @height.times do |height|
      @width.times do |width|
        if @user_position[height][width] != nil
          putc @user_position[height][width]
        else
          putc '#'
        end
      end
      putc "\n"
    end
  end
end

g = Game.new
g.draw_screen
`echo -e "\e[2J"`
g.draw_screen



#exec('clear')
#g.draw_screen
#sleep 3
#exec('clear')
##system(`clear`)
#g.draw_screen

