require 'zen/core_ext'
require 'zen/log'
require 'zen/helper'
require 'zen/space'
require 'zen/koan'
require 'zen/meditation'
require 'zen/persistence'
require 'zen/persistence/base'
require 'zen/persistence/active_record'
require 'zen/persistence/attribute'
require 'zen/reader'
require 'zen/interfaces'
require 'zen/state'
require 'zen/event'
require 'zen/api/default'
require 'zen/api/stateful'

module Zen
  DEFAULT_OPTIONS = { :meta => {} }
  DEFAULT_KOAN    = :om

  def self.included( klass )
    klass.extend( API::Default::ClassMethods )
    klass.send( :include, API::Default::InstanceMethods )
  end

end
