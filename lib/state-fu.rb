#!/usr/bin/env ruby
#
# StateFu Machine:
#
# Teach your ruby objects the path
# to a stateful enlightenment

require 'state_fu/core_ext'
require 'state_fu/logger'
require 'state_fu/helper'
require 'state_fu/exceptions'
require 'state_fu/space'
require 'state_fu/machine'
require 'state_fu/reader'
require 'state_fu/meditation'
require 'state_fu/persistence'
require 'state_fu/persistence/base'
require 'state_fu/persistence/active_record'
require 'state_fu/persistence/attribute'
require 'state_fu/phrase'
require 'state_fu/state'
require 'state_fu/event'
require 'state_fu/hooks'
require 'state_fu/interface'

module StateFu
  DEFAULT_KOAN    = :om

  def self.included( klass )
    klass.extend(         Interface::ClassMethods )
    klass.send( :include, Interface::InstanceMethods )
  end
end

if __FILE__ == $0
  # run rake stuff (specs / doc )
  # load example_machine.rb
  # drop into irb
end
