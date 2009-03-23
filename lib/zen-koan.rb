#!/usr/bin/env ruby
#
# Zen Koan:
#
# Teach your ruby objects the path
# to a stateful enlightenment


require 'zen/core_ext'
require 'zen/logger'
require 'zen/exceptions'
require 'zen/helper'
require 'zen/space'
require 'zen/koan'
require 'zen/reader'
require 'zen/meditation'
require 'zen/persistence'
require 'zen/persistence/base'
require 'zen/persistence/active_record'
require 'zen/persistence/attribute'
require 'zen/interfaces' # s// state_event_interface
require 'zen/state'
require 'zen/event'
require 'zen/hooks'
require 'zen/api/default'
require 'zen/api/stateful'

module Zen
  DEFAULT_KOAN    = :om

  def self.included( klass )
    klass.extend(         API::Default::ClassMethods )
    klass.send( :include, API::Default::InstanceMethods )
  end
end

if __FILE__ == $0
  # run rake stuff (specs / doc )
  # load example_koan.rb
  # drop into irb
end
