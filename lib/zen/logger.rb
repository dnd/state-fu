require 'logger'

module Zen
  Logger       = ::Logger.new( STDOUT )
  Logger.level = ::Logger.const_get( (ENV["ZEN_LOGLEVEL"] || 'WARN').upcase )
end
