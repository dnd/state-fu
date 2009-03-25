#!/usr/bin/env ruby
#
# StateFu Koan:
#
# Teach your ruby objects the path
# to a stateful enlightenment

require 'zen/core_ext'
require 'zen/logger'
require 'zen/helper'
require 'zen/exceptions'
require 'zen/space'
require 'zen/koan'
require 'zen/reader'
require 'zen/meditation'
require 'zen/persistence'
require 'zen/persistence/base'
require 'zen/persistence/active_record'
require 'zen/persistence/attribute'
require 'zen/phrase'
require 'zen/state'
require 'zen/event'
require 'zen/hooks'
require 'zen/interface'

module StateFu
  DEFAULT_KOAN    = :om

  def self.included( klass )
    klass.extend(         Interface::ClassMethods )
    klass.send( :include, Interface::InstanceMethods )
  end
end

if __FILE__ == $0
  # run rake stuff (specs / doc )
  # load example_koan.rb
  # drop into irb
end
