
require 'logger'
module StateFu
  #
  # TODO - SPEC ME GOOD
  #
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

    DEFAULT_SHARED_LOG_PREFIX = '[StateFu] '

    @@prefix    = DEFAULT_SHARED_LOG_PREFIX
    @@logger    = nil
    @@suppress  = false
    @@shared    = false
    @@log_level = nil

    def self.new( log = $stdout, level = () )
      self.instance = get_logger( log )
    end

    def self.parse_log_level(input)
      case input
      when String, Symbol
        const_get( input )
      when 0,1,2,3,4,5
        input
      when nil
        level
      else
        raise ArgumentError
      end
    end

    def self.initial_log_level
      if env_level = ENV[ENV_LOG_LEVEL]
        parse_log_level( env_level )
      else
        DEFAULT_LEVEL
      end
    end

    def self.level
      @@log_level ||= initial_log_level
    end

    def self.level=( new_level )
      @@log_level = parse_log_level(new_level)
    end

    def self.shared?
      !! @@shared
    end

    def self.prefix
      shared? ? @@prefix : nil
    end

    # setter for logger instance
    def self.use_logger( logger, options={:shared => false } )
      @@logger = logger
      @@shared = !!options.symbolize_keys![:shared]
      if shared?
        @@prefix = options[:prefix] || DEFAULT_SHARED_LOG_PREFIX
        puts "shared :: #{@@prefix} #{prefix}"
      end
      if lvl = options[:level] || options[:log_level]
        self.level = lvl
      end
      instance
    end

    def self.instance
      @@logger ||= get_logger($stdout)
    end

    def self.get_logger( logr = $stdout )
      if Object.const_defined?( "RAILS_DEFAULT_LOGGER" )
        use_logger RAILS_DEFAULT_LOGGER, :shared => true
      else
        if Object.const_defined?( 'ActiveSupport' ) && ActiveSupport.const_defined?('BufferedLogger')
          use_logger( ActiveSupport::BufferedLogger.new( logr ))
        else
          use_logger ::Logger.new( logr )
        end
      end
    end

    def self.suppress!
      @@suppress = true
    end

    def self.suppressed?( severity = DEBUG )
      @@suppress == true || severity < level
    end

    def self.add(severity, message = nil, progname = nil, &block)
      severity = parse_log_level( severity )
      return if suppressed?( severity )
      message = [@@prefix, (message || (block && block.call) || progname).to_s].compact.join
      # If a newline is necessary then create a new message ending with a newline.
      # Ensures that the original message is not mutated.
      message = "#{message}\n" unless message[-1] == ?\n
      instance.add( severity, message )
    end

    def self.debug(progname = nil, &block);   add( DEBUG, progname, &block)   end
    def self.info(progname = nil, &block);    add( INFO, progname, &block)    end
    def self.warn(progname = nil, &block);    add( WARN, progname, &block)    end
    def self.error(progname = nil, &block);   add( ERROR, progname, &block)   end
    def self.fatal(progname = nil, &block);   add( FATAL, progname, &block)   end
    def self.unknown(progname = nil, &block); add( UNKNOWN, progname, &block) end

  end
end

