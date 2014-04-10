#require 'singleton'
require 'logger'

class DevLog
  @@singleton_obj = nil
  @@loggetatus = nil
#include Singleton
  private_class_method :new
  def initialize
    @@logger = Logger.new('/home/ogura/work/my_project/game/client/log/client_dev_log.txt')
    @@logger.level = Logger::WARN
  end
  def self.get_instance
    if @@singleton_obj == nil
      @@singleton_obj = new
    end
    @@singleton_obj
  end
  def write(message)
    caller()[0] =~ /(.*?):(\d+)/
    filename, linenum = $1, $2
    @@logger.error  "#{filename}:#{linenum}"
    @@logger.error message.to_s
    abort
  end
end
