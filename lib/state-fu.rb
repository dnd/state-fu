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
require 'state_fu/fu_space'
require 'state_fu/machine'
require 'state_fu/lathe'
require 'state_fu/binding'
require 'state_fu/persistence'
require 'state_fu/persistence/base'
require 'state_fu/persistence/active_record'
require 'state_fu/persistence/attribute'
require 'state_fu/sprocket'
require 'state_fu/state'
require 'state_fu/event'
require 'state_fu/hooks'
require 'state_fu/interface'
require 'state_fu/transition'

module StateFu
  DEFAULT_MACHINE    = :state_fu

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
