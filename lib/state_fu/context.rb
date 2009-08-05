module StateFu
  # abstract superclass of StateFu::Binding and StateFu::Transition. both of
  # these classes share a common interface, and both can be passed to either
  # named procs, or methods defined on your stateful objects, to encapsulate context.

  class Context
    include ContextualEval
  end
end