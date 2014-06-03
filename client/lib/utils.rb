module Utils
  def current_path
    File.dirname(__FILE__).to_s
  end
  def self.r_find(o,search_key)
    puts 'here'
    if o.is_a?(Hash) && o.key?(search_key)
      o[search_key]
    elsif o.respond_to?(:each)
      ret = nil
      o.find{ |*a| ret= r_find(a.last, search_key)}
      ret
    end
  end


end
