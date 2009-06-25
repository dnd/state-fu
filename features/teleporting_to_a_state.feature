Feature: change a binding's state without requirement checks or transitions
  As a developer
  In order to easily test StateFu
  And because I want the freedom to shoot myself in the foot,
  I want to be able to set the state of a binding without any constraints or side effects.

Scenario: calling #teleport to move to an unreachable state
  Given I have included StateFu in a class called MyClass
  And   I have defined this machine
  """
  MyClass.machine(:teleporter) do
    initial_state :secret_laboratory
    state :bank_vault
  end
  """
  And   I create an instance of MyClass called @my_obj
  Then  @my_obj.teleporter.state_name equals :secret_laboratory
  When  I call @my_obj.teleporter.teleport!(:bank_vault)
  Then  @my_obj.teleporter.state_name should equal :bank_vault

Scenario: calling #teleport to avoid event conditions and behaviuors
  Given I have included StateFu in a class called MyClass
  And   I have defined this machine
  """
  MyClass.machine(:marital_status) do
    state :married do
      event :divorce, :to => :single
      requires :paperwork
      requires :lawyer
      on_exit :lose_half_of_everything!
    end
  end
  """
  And   I create an instance of MyClass called @my_obj
  And   @my_obj.marital_status.name equals :married
  When  I call @my_obj.marital_status.teleport!( :single )
  Then  @my_obj.marital_status.name should equal :single
  And   I should not have to pay my ex-wife anything
