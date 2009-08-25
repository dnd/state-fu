Feature: methods defined on inclusion of StateFu

  When StateFu is included into a class, it should gain a few methods:

   * class methods which allow us to define and access one or more
     instances of StateFu::Machine, which defines a workflow / state
     machine

   * instance methods so that we can access a StateFu::Binding, which
     encapsulates a reference to a StateFu::Machine, an object, and
     its current state in that Machine, as well as providing other
     methods for interacting with StateFu.

Scenario: including StateFu into a class should define class methods to access StateFu::Machines
  Given I have required the StateFu library
  When I include StateFu in a class called MyClass
  Then MyClass should respond to 'state_fu_machine'
  Then MyClass should respond to 'machine'  
  And  MyClass should respond to 'state_fu_machines'
  And  MyClass should respond to 'machines'  


Scenario: including StateFu into a class should define aliases for class methods
  Given I have required the StateFu library
  When I include StateFu in a class called MyClass
  Then MyClass should respond to 'stfu'           as an alias for 'machine'
  Then MyClass should respond to 'state_fu'       as an alias for 'machine'
  Then MyClass should respond to 'workflow'       as an alias for 'machine'
  Then MyClass should respond to 'stateful'       as an alias for 'machine'
  Then MyClass should respond to 'statefully'     as an alias for 'machine'
  Then MyClass should respond to 'state_machine'  as an alias for 'machine'
  Then MyClass should respond to 'engine'         as an alias for 'machine'

  Then MyClass should respond to 'workflows'      as an alias for 'machines'
  Then MyClass should respond to 'engines'        as an alias for 'machines'


Scenario: calling MyClass.machine should return a StateFu::Machine bound to MyClass
  Given I have included StateFu in a class called MyClass
  When I invoke the class method MyClass.machine
  Then I should receive a StateFu::Machine
  And it should be bound to MyClass with the name :default
  And it should return the same StateFu::Machine on subsequent invocations of MyClass.machine

Scenario: calling MyClass.machine with a block should define that machine's states and events
  Given I have included StateFu in a class called MyClass
  When I call
  """
  MyClass.machine do
    state :frightened do
      event :scare, :to => :petrified
    end
  end
  """
  And I create an instance of MyClass called @my_obj
  Then I should receive a StateFu::Machine
  And it should be bound to MyClass with the name :default
  And it should return the same StateFu::Machine on subsequent invocations of MyClass.machine
  And the machine should have a StateFu::State called :frightened
  And the machine should have a StateFu::Event called :scare

Scenario: instantiating a binding to a Machine which has an event should define event methods on the instance
  Given I have included StateFu in a class called MyClass
  When I call
  """
  MyClass.machine do
    state :frightened do
      event :scare, :to => :petrified
    end
  end
  """
  And I create an instance of MyClass called @my_obj
  And I call @my_obj.state_fu
  Then I should receive a StateFu::Binding
  And @my_obj should respond to 'can_scare?'
  And @my_obj should respond to 'scare!'
  And @my_obj.can_scare? should be true
  And @my_obj.scare! should cause an event transition

Scenario: calling MyClass.state_fu_machines should return a list of machines for MyClass
  Given I have included StateFu in a class called MyClass
  And I have defined an empty default machine for MyClass
  When I invoke the class method MyClass.state_fu_machines
  Then I should get a hash of StateFu::Machines and their names
  And it should contain one Machine with the default name :default

Scenario: including StateFu into a class should define instance methods to access StateFu::Bindings
  Given I have required the StateFu library
  When I include StateFu in a class called MyClass
  And I create an instance of MyClass called @my_obj
  Then @my_obj should respond to 'state_fu'
  And  @my_obj should respond to 'bindings'
  And  @my_obj should respond to 'state_fu!'

Scenario: the state_fu instance method should return a StateFu::Binding
  Given I have required the StateFu library
  When I include StateFu in a class called MyClass
  When I invoke the class method MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I call @my_obj.state_fu
  Then I should receive a StateFu::Binding
  And it should refer to the default StateFu::Machine for MyClass
  And I should receive the same StateFu::Binding on successive invocations

Scenario: the bindings instance method should return an empty Hash when no Bindings have been instantiated
  Given I have required the StateFu library
  And I include StateFu in a class called MyClass
  And I invoke the class method MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I have not called @my_obj.state_fu
  When I call @my_obj.bindings
  Then I should receive a Hash
  And it should be empty

Scenario: the bindings instance method should return a hash of instantiated StateFu::Bindings
  Given I have required the StateFu library
  And I include StateFu in a class called MyClass
  And I invoke the class method MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I call @my_obj.state_fu
  When I call @my_obj.bindings
  Then I should receive a Hash
  And it should have one element
  And it should include the machine name :default in its keys
  And it should have a binding to the default StateFu::Machine for the class in its values

Scenario: the state_fu! instance method should instantiate all bindings
  Given I have required the StateFu library
  And I include StateFu in a class called MyClass
  And I invoke the class method MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I have not called @my_obj.state_fu
  When I call @my_obj.state_fu!
  Then I should receive an Array
  And it should have one element
  And it should contain a binding to the default StateFu::Machine for the class
  And @my_obj.bindings should not be empty
