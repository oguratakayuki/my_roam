require 'singleton'
class ApplicationContext
  include Singleton
  def tcp_client=(tc)
    @tcp_client = tc
  end
  def tcp_client
    @tcp_client
  end
  def server_queue
    @s_q ||= @tcp_client.create_receive_process
  end
  def client_queue
    client_queue_initialize
    client_queue_start
    @c_q.queue
  end
  #client_event.start

  def client_queue_initialize
    @c_q ||= ClientEvent.new
  end
  def client_queue_start
    @c_q.start unless @c_q.started?
  end
  def set_user_info(hash)
    @user_info ||= {}
    [:user_id, :user_name, :password, :job_id].each do |key|
      @user_info[key] = Utils::r_find(hash, key)
    end
  end
  def user_info(key=nil)
    key ? @user_info[key] : @user_info
  end

end


