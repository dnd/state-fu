require 'logger'

module StateFu
  if Object.const_defined?( "RAILS_DEFAULT_LOGGER" )
    Logger       = RAILS_DEFAULT_LOGGER
  else
    Logger       = ::Logger.new( STDOUT )
    Logger.level = ::Logger.const_get( (ENV["ZEN_LOGLEVEL"] || 'WARN').upcase )
  end
end
