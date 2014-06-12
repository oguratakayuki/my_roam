class Map

  def initialize
    @width = 60
    @height = 30
    @map = Array.new((@height+1)).map{Array.new((@width+1),nil)}
    @mutex = Mutex.new
    @logger = Logger.new('./log/map_log')
    @logger.level = Logger::WARN
  end

  def find(x,y)
    @map[y][x]
  end

  def find_user_id(x, y)
    #x, y = normalize_index(x, y)
    if is_exist_position?(x, y) && @map[y][x] != nil && ['user', 'enemy'].include?(@map[y][x][:type])
      @map[y][x][:user_id]
    end
  end

  def find_map(user_id)
    @map.each_with_index do |list, y_index|
      list.each_with_index do |pos, x_index|
        #unless is_empty_position?(x_index, y_index)
        unless pos.nil?
          if pos[:user_id].to_s == user_id.to_s
            return {:x => x_index, :y => y_index }
          end
        end
      end
    end
    return false
  end


  def x_y_with_direction(x, y, direction)
    case direction
    when 'up'
      y = y.to_i - 1
    when 'down'
      y = y.to_i + 1
    when 'left'
      x = x.to_i - 1
    when 'right'
      x = x.to_i + 1
    end
    is_exist_position?(x, y) ? {:x => x, :y => y} : {}
  end

  def count_down_effect
puts 'REMOVE START!!!!!!!!!11'
    @map.each_with_index do |list, y_index|
      list.each_with_index do |pos, x_index|
        #unless is_empty_position?(x_index, y_index)
        unless pos.nil?
          if pos.key?(:attr) && pos[:attr].key?(:effect_life_time) && pos.key?(:type) && ['user','enemy'].include?(pos[:type])
            #type=>user, :attr => { :effect => 'attacked', :effect_life_time => 5 } }
            pos[:attr][:effect_life_time] = pos[:attr][:effect_life_time] -1
            if pos[:attr][:effect_life_time] < 1
              pos[:attr].delete(:effect)
              pos[:attr].delete(:effect_life_time)
            end
          elsif pos.key?(:type) && pos[:type] == 'effect' && pos[:attr].key?(:effect_life_time)
puts 'TRY TO EFFECT REMOVED2'
            #effect_only element
            #type=>effect, :attr => { :effect_type => , :effect_life_time => 5 } }
            pos[:attr][:effect_life_time] = pos[:attr][:effect_life_time] -1
            #set(x,y, 'effect', attr={:effect_type => 'attack_fail', :effect_life_time => 5 } )
            if pos[:attr][:effect_life_time] < 1
puts 'EFFECT REMOVED2'
              #pos = nil
              unset(x_index, y_index, 'effect', nil)
            end
          end
        end
      end
    end
    return false
  end

  def dump
    @map.each_with_index do |list, y_index|
      list.each_with_index do |pos, x_index|
        #unless is_empty_position?(x_index, y_index)
        unless pos.nil?
          print pos[:user_id]
          #abort 'here'
        else
          print '#'
        end
      end
      print "\n"
    end
  end

  def export
    results = []
    @map.each_with_index do |list, y_index|
      list.each_with_index do |pos, x_index|
        unless pos.nil?
          #abort 'here'
          temp = pos.merge(:x => x_index, :y => y_index)
          results << temp
        end
      end
    end
    return results
  end

  def find_free_space
    result = []
    @map.each_with_index do |list, y_index|
      list.each_with_index do |pos, x_index|
        if is_empty_position?(x_index, y_index)
          result << {'x' => x_index, 'y' => y_index }
        end
      end
    end
    result
  end

  def move(user_type, user_id, from_x, from_y, to_x, to_y)
    result = false
    @mutex.lock
    begin
      #if is_empty_position?(to_x, to_y)
      if is_empty_position?(to_x, to_y) && is_exist_position?(to_x, to_y)
        @logger.error "move ok #{[to_x, to_y].to_s}"
        ret = unset(from_x, from_y, user_type, user_id) if from_x != nil && from_y != nil
puts "unset result = #{ret.to_s}"
        if ret && ret.key?(:attr)
puts "attr exists!!!!"
          set(to_x, to_y, user_type, user_id, attr=ret[:attr])
        else
          set(to_x, to_y, user_type, user_id)
        end
        result = true
      else
        @logger.error "move fail #{[to_x, to_y].to_s}"
        result = false
      end
    ensure
      @mutex.unlock
    end
    return result
  end

  def add_attacked_effect(attacked_user_id)
    #elementのeffect属性を更新する
    pos = find_map(attacked_user_id)
    puts "attacked_user_id = #{attacked_user_id}, pos = #{pos.to_s}"
    if pos != false
      puts "find attacked position!"
      set_effect_attr(pos[:x], pos[:y], effect_type='attacked')
    end
  end

  def is_exist_position?(x, y)
    #x, y = normalize_index(x, y)
    ( 0 < x && x < @width ) && ( 0 < y && y < @height ) ? true : false
  end
  def is_empty_position?(x, y)
      #x, y = normalize_index(x, y)
      return @map[y][x] == nil ? true : false
  end

  def add_attack_fail_effect(x, y, weapon_id, direction)
    #element自体をつくる
    set(x,y, 'effect', element_id =nil, attr={:effect_type => 'attack_fail', :effect_life_time => 2, :weapon_id => weapon_id, :direction => direction } )
  end

  private
  def set_effect_attr(x, y, effect_type)
    puts "herere! set_effect_attr param = x=#{x}, y=#{y},type=#{effect_type}"
    if @map[y][x]
      @map[y][x][:attr][:effect] = effect_type
      @map[y][x][:attr][:effect_life_time] = 2
    end
  end

  def set(x, y, type, element_id, attr ={})
    #x, y = normalize_index(x, y)
    if is_empty_position?(x, y)
      if type == 'user'
        @map[y][x] = {:type => 'user', :user_id => element_id, :attr => attr}
      elsif type == 'enemy'
        @map[y][x] = {:type => 'enemy', :user_id => element_id, :attr => attr}
      elsif type == 'object'
        @map[y][x] = {:type => 'object', :object_id => element_id, :attr => {}}
      elsif type == 'effect'
        @map[y][x] = {:type => 'effect', :user_id => nil, :attr => attr}
        puts '!!!!!!!!!!!effect is set!!!'
      end
      true
    else
      false
    end
  end

  def unset(x, y, type, element_id)
    #x, y = normalize_index(x, y)
    if type == 'user' || type == 'enemy'
      if @map[y][x][:type] == type && @map[y][x][:user_id] == element_id
        ret = @map[y][x].dup
        @map[y][x] = nil
        return ret
      end
    elsif type == 'object'
      if @map[y][x][:type] == type && @map[y][x][:object_id] == element_id
        @map[y][x] = nil
      end
    elsif type == 'effect'
      @map[y][x] = nil
    end
  end
  def normalize_index(x, y)
    return [x-1, y-1]
  end
end

#map = Map.new
#map.set(1,2, 'user', 9)
#map.unset(1,2, 'user', 9)
#if map.set(1,2, 'user', 8)
#  puts 'success'
#else
#  puts 'fail'
#end
#map.dump
