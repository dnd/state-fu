#!/usr/bin/env ruby
#
# State-Fu
#
# State-Fu is a framework for state-oriented programming in ruby.
#
# You can use it to define state machines, workflows, rules engines,
# and the behaviours which relate to states and transitions between
# them.
#
# It is powerful and flexible enough to drive entire applications, or
# substantial parts of them. It is designed as a library for authors,
# as well as users, of libraries: State-Fu goes to great lengths to
# impose very few limits on your ability to introspect, manipulate and
# extend the core features.
#
# It is also delightfully elegant and easy to use for simple things:
#
#   class Document < ActiveRecord::Base
#     include StateFu
#
#     def update_rss
#       puts "new feed!"
#       # ... do something here
#     end
#
#     machine( :status ) do
#       state :draft do
#         event :publish, :to => :published
#       end
#
#       state :published do
#         on_entry :update_rss
#         requires :author  # a database column
#       end
#
#       event :delete, :from => :ALL, :to => :deleted do
#         execute :destroy
#       end
#     end
#   end
#
#  my_doc = Document.new
#
#  my_doc.status                          # returns a StateFu::Binding, which lets us access the 'Fu
#  my_doc.status.state     => 'draft'     # if this wasn't already a database column or attribute, an
#                                         # attribute has been created to keep track of the state
#  my_doc.status.name      => :draft      # the name of the current_state (defaults to the first defined)
#  my_doc.status.publish!                 # raised =>  StateFu::RequirementError: [:author]
#                                         # the author requirement prevented the transition
#  my_doc.status.name      => :draft      # see? still a draft.
#  my_doc.author = "Susan"                # so let's satisfy it ...
#  my_doc.publish!                        # and try again
#  "new feed!"                            # aha - our event hook fires!
#  my_doc.status.name      => :published  # and the state has been updated.

require 'rubygems'
# require 'activesupport'

[ 'core_ext',
  'logger',
  'helpers/applicable',
  'helpers/contextual_eval',
  'helpers/transitive',
  'helpers/arrays',
  'context',
  'exceptions',
  'fu_space',
  'machine',
  'lathe',
  'method_factory',
  'binding',
  'persistence',
  'persistence/base',
  'persistence/active_record',
  'persistence/attribute',
  'persistence/relaxdb',
  'sprocket',
  'state',
  'event',
  'hooks',
  'interface',
  'transition',
  'mock_transition',
  'plotter' ].each do |lib|
  require File.expand_path( File.join( File.dirname(__FILE__), 'state_fu', lib ))
end

module StateFu
  DEFAULT_MACHINE    = :state_fu

  def self.included( klass )
    klass.extend(         Interface::ClassMethods )
    klass.send( :include, Interface::InstanceMethods )
    klass.extend(         Interface::Aliases )
  end
end

if __FILE__ == $0
  # drop into irb?
end

