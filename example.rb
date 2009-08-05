require 'lib/state-fu'

class Foo
  include StateFu

  machine do
    initial_state :alpha

    event :ab, :from => {:alpha => :beta}
    event :xy, :from => {:xerox => :yellow}
    event :bx, :from => {:beta => :xerox}
  end
end
