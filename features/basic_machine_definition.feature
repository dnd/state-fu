Feature: defining a StateFu::Machine
  As a developer
  In order to use a StateFu::Machine in my class instances
  I want to be able to define one or more simple Machines for a class

Scenario: defining an empty StateFu::Machine with the default name :state_fu
  Given I have included StateFu in a class called MyClass
  When I call the class method MyClass.machine
  Then I should receive a StateFu::Machine
  And it should be bound to MyClass with the name :state_fu

Scenario: defining a simple state in the machine block
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      state :ready
    end
  """
  Then I should receive a StateFu::Machine
  And it should have a StateFu::State called :ready
  And I can retrieve a StateFu::State by calling states[:ready] on the machine
  And the state should have the name :ready

Scenario: adding states to a machine with successive machine blocks
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      state :ready
    end

    MyClass.machine do
      state :set
    end
  """
  Then I should receive a StateFu::Machine
  And it should have a StateFu::State called :ready
  And it should have a StateFu::State called :set
  And I can retrieve a StateFu::State by calling states[:ready] on the machine
  And the state should have the name :ready
  And I can retrieve a StateFu::State by calling states[:set] on the machine
  And the state should have the name :set

Scenario: defining multiple states at once with the states method
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      # note that 'go' is converted to the symbol :go -
      # state and event names are always symbols
      states :ready, :set, 'go'
    end
  """
  Then I should receive a StateFu::Machine
  And the machine should have a StateFu::State called :ready
  And the machine should have a StateFu::State called :set
  And the machine should have a StateFu::State called :go

Scenario: default initial state of a machine is the first state defined
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      states :ready, :set, :go
    end
  """
  Then I should receive a StateFu::Machine
  And the machine should have an initial_state called :ready

Scenario: explicitly setting the initial state of a machine
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      states :ready, :set, :go
      initial_state :before
    end
  """
  Then I should receive a StateFu::Machine
  And the machine should have a StateFu::State called :before
  And the machine should have an initial_state called :before
  And the machine should have a list of states with four StateFu::States
  And the StateFu::State called :before should be last in the list

Scenario: adding metadata / options to a state
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      # note: option keys are converted to symbols if supplied as strings
      states :ready, :set, :go

      states :ready, :set, 'running' => false
      state :go,           :running  => true

      state :ready, :colour => 'black'
      state :set,   :colour => 'amber'
      state :go,    :colour => 'green'

      # it is also possible to modify the options by getting a direct reference
      # to the state and using the 'options' accessor method -
      # if you really want your key to be a string this is what you'll have to do
      state :disqualified do |s|
        s.options['sponsor_payment'] = false
      end
    end

    MyClass.machine do
      # replace the colour 'black' with 'red' and add a stance to the options
      state :ready, :colour => 'red', :stance => :crouch
    end

    # MyClass.machine.states[:ready].options
    # => returns the options Hash for the state called :ready
  """
  Then I should receive a StateFu::Machine
  And the machine should have a StateFu::State called :ready
  And I can retrieve a StateFu::State by calling states[:ready] on the machine
  And the state should have an option :colour with the value 'red'
  And the state should have an option :running with the value false
  And I can retrieve a StateFu::State by calling states[:set] on the machine
  And the state should have an option :colour with the value 'amber'
  And the state should have an option :running with the value false
  And I can retrieve a StateFu::State by calling states[:go] on the machine
  And the state should have an option :colour with the value 'green'
  And the state should have an option :running with the value true
  And I can retrieve a StateFu::State by calling states[:disqualified] on the machine
  And the state should have an option "sponsor_payment" with the value false

Scenario: adding simple events to a machine
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      # note that states are created implicitly when referenced by an event.

      # these are functionally equivalent syntaxes:
      event :eat, :from => :hungry, :to => :satiated

      event :gorge do
        from :hungry
        to   :stuffed
      end
    end
  """
  Then I should receive a StateFu::Machine
  And the machine should have a StateFu::Event called :eat
  And the machine should have a StateFu::State called :hungry
  And the machine should have a StateFu::State called :satiated
  And I can retrieve a StateFu::Event by calling events[:eat] on the machine
  And the event's origin should be the StateFu::State called :hungry
  And the event's target should be the StateFu::State called :satiated
  And the event should be simple?

Scenario: adding metadata / options to an event
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      state :normal do
        events :cancel, :delete, :colour => 'turqoise'
        event :cancel, :role => :user  do
          to :cancelled
        end
        event :delete, :role => :system do
          to :deleted
        end
      end
    end
  """
  Then I should receive a StateFu::Machine
  And the machine should have a StateFu::Event called :cancel
  And I can retrieve a StateFu::Event by calling events[:cancel] on the machine
  And the event should have the name :cancel
  And the event's origin should be the StateFu::State called :normal
  And the event should have an option :colour with the value 'turqoise'
  And the event should have an option :role with the value :user
  And I can retrieve a StateFu::Event by calling events[:delete] on the machine
  And the event should have the name :delete
  And the event's origin should be the StateFu::State called :normal
  And the event should have an option :colour with the value 'turqoise'
  And the event should have an option :role with the value :system

Scenario: adding simple events to a machine with shorthand syntax
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      event :eat, :from => {:hungry => :satiated}
    end
  """
  Then I should receive a StateFu::Machine
  And I can retrieve a StateFu::Event by calling events[:eat] on the machine
  And the event's origin should be the StateFu::State called :hungry
  And the event's target should be the StateFu::State called :satiated

Scenario: adding simple events to a machine with shorthand block syntax
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      event( :eat ) { from :hungry => :satiated }
    end
  """
  Then I should receive a StateFu::Machine
  And I can retrieve a StateFu::Event by calling events[:eat] on the machine
  And the event's origin should be the StateFu::State called :hungry
  And the event's target should be the StateFu::State called :satiated

Scenario: adding simple states and events to a machine with dot-like syntax
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      chain 'new -save-> saved -update-> updated -delete-> deleted saved -delete-> deleted'
      chain 'updated    -update->     updated'
    end
  """
  Then I should receive a StateFu::Machine
  And the machine should have an initial_state called :new
  And the machine should have a StateFu::State called :saved
  And the machine should have a StateFu::State called :updated
  And the machine should have a StateFu::State called :deleted
  And the event :save   should transition from :new     to :saved
  And the event :update should transition from :saved   to :updated
  And the event :delete should transition from :updated to :deleted
  And the event :update should transition from [:saved, :updated] to :updated
  And the event :delete should transition from [:updated, :saved] to :deleted

Scenario: adding events to a machine with multiple origins & targets
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      event :eat, :from => [:hungry, :peckish], :to => [:satiated, :full]
    end
  """
  Then I should receive a StateFu::Machine
  And I can retrieve a StateFu::Event by calling events[:eat] on the machine
  And the event's origin should be nil
  And the event's target should be nil
  And the event should not be simple?
  And the event's origins should include the StateFu::State called :hungry
  And the event's targets should include the StateFu::State called :satiated

Scenario: adding events to a machine with multiple origins & targets with shorthand syntax
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
      event :eat, :from => {[:hungry, :peckish] => [:satiated, :full]}
    end
  """
  Then I should receive a StateFu::Machine
  And I can retrieve a StateFu::Event by calling events[:eat] on the machine
  And the event's origin should be nil
  And the event's target should be nil
  And the event's origins should include the StateFu::State called :hungry
  And the event's origins should include the StateFu::State called :peckish
  And the event's targets should include the StateFu::State called :satiated
  And the event's targets should include the StateFu::State called :full
  And the event should not be simple?

Scenario: adding an event from inside a state block in the machine definition
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine do
     # including the event inside a state block is equivalent to
     # declaring that it is :from that state
      state :poor do
        event :get_rich_quick, :to => :rich
      end

      state :middle_class do
        event :get_rich_quick, :to => :filthy_rich
      end
    end
  """
  Then I should receive a StateFu::Machine
  And I can retrieve a StateFu::Event by calling events[:get_rich_quick] on the machine
  And the event's target should be nil
  And the event's origin should be nil
  And the event's origins should include the StateFu::State called :poor
  And the event's origins should include the StateFu::State called :middle_class
  And the event's targets should include the StateFu::State called :rich
  And the event's targets should include the StateFu::State called :filthy_rich

Scenario: multiple machines bound to the the same class
  Given I have included StateFu in a class called MyClass
  When I call
  """
    MyClass.machine(:thread_status) do
      states :idle, :active, :sleeping, :zombie, :colour => 'tartan'
    end

    MyClass.machine(:undead_status) do
      states :alive, :dead, :vampire, :zombie, :colour => 'black'
      event :decay, :from => { :zombie => :skeleton }
    end
  """
  Then MyClass.machines should be of size 2
  And MyClass.machines(:thread_status) should return a StateFu::Machine
  And the machine should have a StateFu::State called :idle
  And the machine should have a StateFu::State called :active
  And the machine should have a StateFu::State called :sleeping
  And the machine should have a StateFu::State called :zombie
  And the machine should not have any StateFu::Event
  And the machine should not have a StateFu::State called :vampire
  And MyClass.machines(:undead_status) should return a StateFu::Machine
  And the machine should have a StateFu::State called :alive
  And the machine should have a StateFu::State called :dead
  And the machine should have a StateFu::State called :vampire
  And the machine should have a StateFu::State called :zombie
  And the machine should have a StateFu::Event called :decay
  And the two StateFu::States called :zombie should be different objects



