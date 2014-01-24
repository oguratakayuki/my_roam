class Map
  def initialize
    @width = 60
    @height = 30
    @map = Array.new(@height).map{Array.new(@width,nil)}
    @mutex = Mutex.new
  end
  def find(x,y)
    @map[y][x]
  end
  def dump
    @map.each_with_index do |list, y_index|
      list.each_with_index do |pos, x_index|
        unless is_empty_position?(x_index, y_index)
          print pos[:user_id]
        else
          print '#'
        end
      end
      print "\n"
    end
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

  def move(user_id, from_x, from_y, to_x, to_y)
    result = false
    @mutex.lock
    begin
      if is_empty_position?(to_x, to_y)
        unset(from_x, from_y, 'user', user_id) if from_x != nil && from_y != nil
        set(to_x, to_y, 'user', user_id)
        result = true
      else
        result = false
      end
    ensure
      @mutex.unlock
    end
    return result
  end


  def is_exist_position?(x, y)
    return x < @width && y < @height
  end
  def is_empty_position?(x, y)
      return @map[y][x] == nil ? true : false
  end


  private
  def set(x, y, element_type, element_id)
    x, y = normalize_index(x, y)
    if is_empty_position?(x, y)
      if element_type == 'user'
        @map[y][x] = {:type => 'user', :user_id => element_id}
      elsif element_type == 'object'
        @map[y][x] = {:type => 'user', :object_id => element_id}
      end
      true
    else
      false
    end
  end
  def unset(x, y, element_type, element_id)
    x, y = normalize_index(x, y)
    if element_type == 'user'
      if @map[y][x][:type] == element_type && @map[y][x][:user_id] == element_id
        @map[y][x] = nil
      end
    elsif element_type == 'object'
      if @map[y][x][:type] == element_type && @map[y][x][:object_id] == element_id
        @map[y][x] = nil
      end
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