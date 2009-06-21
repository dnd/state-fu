Feature: methods defined on inclusion of StateFu

  When StateFu is included into a class, it should define a few methods:

   * class methods so that we can define and access one or more
     instances of StateFu::Machine, which contain

   * instance methods so that we can access a StateFu::Binding, which
     encapsulates a Machine, an object, and its current state in that Machine.

Scenario: including StateFu into a class should define class methods to access StateFu::Machines
  Given I have required the StateFu library
  When I include StateFu in a class called MyClass
  Then MyClass should respond to 'machine'
  And  MyClass should respond to 'machines'
  And  MyClass should respond to 'machine_names'

Scenario: calling MyClass.machine should return a StateFu::Machine bound to MyClass
  Given I have included StateFu in a class called MyClass
  When I call MyClass.machine
  Then I should get a StateFu::Machine
  And It should be bound to MyClass with the name :state_fu
  And it should return the same StateFu::Machine on subsequent invocations

Scenario: calling MyClass.machines should return a list of machines for MyClass
  Given I have included StateFu in a class called MyClass
  And I have defined the default machine for MyClass
  When I call MyClass.machines
  Then I should get a hash of StateFu::Machines and their names
  And it should contain one Machine with the default name :state_fu

Scenario: calling MyClass.machine_names should return a list of machine names
  Given I have included StateFu in a class called MyClass
  And I have defined the default machine for MyClass
  When I call MyClass.machine_names
  Then I should get a list of machine names for MyClass
  And it should contain only the default name :state_fu

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
  When I call MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I call @my_obj.state_fu
  Then I should receive a StateFu::Binding
  And it should refer to the default StateFu::Machine for MyClass
  And I should receive the same StateFu::Binding on successive invocations

Scenario: the bindings instance method should return an empty Hash when no Bindings have been instantiated
  Given I have required the StateFu library
  And I include StateFu in a class called MyClass
  And I call MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I have not called @my_obj.state_fu
  When I call @my_obj.bindings
  Then I should receive a Hash
  And it should be empty

Scenario: the bindings instance method should return a hash of instantiated StateFu::Bindings
  Given I have required the StateFu library
  And I include StateFu in a class called MyClass
  And I call MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I call @my_obj.state_fu to instantiate a binding
  When I call @my_obj.bindings
  Then I should receive a Hash
  And it should have one element
  And it should include the default machine name :state_fu in its keys
  And it should have a binding to the default StateFu::Machine for the class in its values

Scenario: the state_fu! instance method should instantiate all bindings
  Given I have required the StateFu library
  And I include StateFu in a class called MyClass
  And I call MyClass.machine
  And I create an instance of MyClass called @my_obj
  And I have not called @my_obj.state_fu
  When I call @my_obj.state_fu!
  Then I should receive an Array
  And it should have one element
  And it should contain a binding to the default StateFu::Machine for the class
  And @my_obj.bindings should not be empty

