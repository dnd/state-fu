require 'logger'

module Zen

  def self.logger
    unless defined? @@logger
      @@logger       = ::Logger.new( STDOUT )
      @@logger.level = ::Logger::WARN
    end
    @@logger
  end

end
