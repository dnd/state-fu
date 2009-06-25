require 'logger'
module StateFu
  class Logger
    cattr_accessor :prefix   # prefix for log messages
    cattr_accessor :suppress # set true to send messages to /dev/null

    DEBUG   = 0
    INFO    = 1
    WARN    = 2
    ERROR   = 3
    FATAL   = 4
    UNKNOWN = 5

    ENV_LOG_LEVEL = 'STATEFU_LOGLEVEL'
    DEFAULT_LEVEL = INFO

    DEFAULT_PREFIX    = nil
    SHARED_LOG_PREFIX = 'StateFu: '

    @@prefix   = DEFAULT_PREFIX
    @@logger   = nil
    @@suppress = false

    def self.level=( new_level )
      instance.level = case new_level
                       when String, Symbol
                         const_get( new_level )
                       when Fixnum
                         new_level
                       else
                         state_fu_log_level()
                       end
    end

    def self.state_fu_log_level
      if ENV[ ENV_LOG_LEVEL ]
        const_get( ENV[ ENV_LOG_LEVEL ] )
      else
        DEFAULT_LEVEL
      end
    end

    def self.new( log = $stdout, level = () )
      self.instance = get_logger( log )
    end

    def self.instance=( logger )
      @@logger ||= get_logger
    end

    def self.instance
      @@logger ||= get_logger
    end

    def self.get_logger( log = $stdout )
      if Object.const_defined?( "RAILS_DEFAULT_LOGGER" )
        logger         = RAILS_DEFAULT_LOGGER
        prefix         = SHARED_LOG_PREFIX
      else
        if Object.const_defined?( 'ActiveSupport' ) && ActiveSupport.const_defined?('BufferedLogger')
          logger       = ActiveSupport::BufferedLogger.new( log )
        else
          logger       = ::Logger.new( log )
          logger.level = state_fu_log_level()
        end
      end
      logger
    end

    def self.suppress!
      @@suppress = true
    end

    # method_missing is usually a last resort
    # but i don't see it causing any headaches here.
    def self.method_missing( method_id, *args )
      return if @@suppress
      if [:debug, :info, :warn, :error, :fatal].include?( method_id ) &&
          args[0].is_a?(String) && @@prefix
        args[0] = @@prefix + args[0]
      end
      instance.send( method_id, *args )
    end

  end
end

# StateFu::Logger.info( StateFu::Logger.instance.inspect )
