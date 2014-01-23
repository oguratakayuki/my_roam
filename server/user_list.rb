class User
  attr_reader :id, :ip, :x, :y, :port
  def initialize(user_id, ip, port)
    @id = user_id
    @ip = ip
    @port = '10006'
    @x = 0
    @y = 0
  end
  def update_position(x,y)
    @x = x
    @y = y
  end
end

class UserList
  def initialize
    @user_list = []
    @last_user_id = 0
    @logger = Logger.new('./log/user_list_log.txt')
    @logger.level = Logger::WARN
  end
  def get_new_user_by_ip(ip, port)
    @last_user_id = @last_user_id + 1
    user = User.new(@last_user_id, ip, port)
    @user_list << user
    user.id
  end
  def get_user_by_position(x, y)
    @user_list.detect{|t| t.x == x && t.y == y}
  end
  def find(user_id)
    user = @user_list.detect{|t| t.id == user_id}
  end
  def update_by_id(user_id, x, y)
    user = @user_list.detect{|t| t.id == user_id}
    user.update_position(x,y)
  end
  def ips_and_ports
    @user_list.map{|user| {:ip => user.ip, :port => user.port}}
  end
  def positions
    @user_list.map{|user| {:user_id => user.id, :ip => user.ip, :x => user.x, :y => user.y } }
  end
end


