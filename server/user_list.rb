class User
  attr_reader :id, :ip, :x, :y, :port, :type, :hp, :user_name
  def initialize(user_id, ip, type=nil, user_name=nil,password=nil)
    @id = user_id
    @ip = ip
    #@port = '10006'
    @port = '10004'
    @x = 0
    @y = 0
    @type = 'user'
    @job_id = nil
    @hp = 100
    @user_name = user_name
    @password = password
    @is_login = false
  end
  def is_login?
    @is_login
  end
  def login
    @is_login = true
  end
  def update_position(x,y)
    @x = x
    @y = y
  end
  def job_id(job_id)
    @job_id = job_id
  end
  def next_pos_by_key(key)
    self.send("#{key.to_s}_pos")
  end
  def left_pos
    {:x => (@x - 1), :y => @y}
  end

  def right_pos
    {:x => (@x + 1), :y => @y}
  end

  def up_pos
    {:x => @x, :y => (@y - 1)}
  end
  def down_pos
    {:x => @x, :y => (@y + 1)}
  end
end

class Enemy < User
  attr_reader :id, :x, :y, :type, :hp, :status, :lock_user_id
  def initialize(enemy_id)
    @id = enemy_id
    @x = 0
    @y = 0
    @type = 'enemy'
    @hp = 100
    @status = 'free'
    @lock_user_id = nil
  end
  def next_action
    randam_walk
  end
  def randam_walk
    key = [:left, :right, :up, :down].sample
    next_pos = next_pos_by_key(key)
    action = {:type => 'walk', :params => {:next_pos => next_pos } }
  end
end

class UserList
  def initialize
    @user_list = []
    @last_user_id = 0
    @logger = Logger.new('./log/user_list_log.txt')
    @logger.level = Logger::WARN
  end
  def get_new_enemy
    @last_user_id = @last_user_id + 1
    enemy = Enemy.new(@last_user_id)
    @user_list << enemy
    enemy
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
  def ips
    @user_list.select{|user| user.type != 'enemy' &&  user.is_login?}.map{|user| {:ip => user.ip, :port => user.port}}
  end
  def infos
    @user_list.map{|user| {:user_id => user.id, :ip => user.ip, :x => user.x, :y => user.y, :type => user.type, :hp => user.hp } }
  end
  def check_user_name(user_name)
    @user_list.detect{|t| t.class == 'User' && t.user_name == user_name } == nil ? true : false
  end
  def user_registration(user_name, password, ip)
    @last_user_id = @last_user_id + 1
    user = User.new(@last_user_id, ip, type = 'user', user_name, password)
    @user_list << user
    user.id
  end
  def user_update(user_id, attributes)
    user = @user_list.detect{|t| t.id == user_id}
    attributes.each do |k,v|
      user.__send__(k, v)
    end
  end

  def user_login(user_id)
    user = @user_list.detect{|t| t.id == user_id}
    user.login
  end

end


