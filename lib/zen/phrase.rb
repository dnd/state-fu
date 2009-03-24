module Zen
  class Phrase # Abstract Superclass of State & Event
    include Zen::Helper # define apply!

    attr_reader :koan, :name, :options, :hooks

    def initialize(koan, name, options={})
      @koan    = koan
      @name    = name.to_sym
      @options = options.symbolize_keys!
      @hooks   = Zen::Hooks.for( self )
    end

    # sneaky way to make some comparisons / duck punching a bit cleaner
    alias_method :to_sym,  :name

    # Bunch of silly little methods for defining events
    # Can no doubt voodoo them away, but is that really a good idea?

    def define_hook *args, &block # type, names, options={}, &block
      options      = args.extract_options!.symbolize_keys!
      type         = args.shift
      method_names = args
      Logger.warn "define_hook: not implemented"
    end

    def add_hook slot, name, value
      @hooks[slot.to_sym] << [name.to_sym, value]
    end

    # Bunch of silly little methods for defining events
    def before   *a, &b; define_hook :before,   *a, &b; end
    def on_exit  *a, &b; define_hook :exit,     *a, &b; end
    def execute  *a, &b; define_hook :execute,  *a, &b; end
    def on_entry *a, &b; define_hook :entry,    *a, &b; end
    def after    *a, &b; define_hook :after,    *a, &b; end
    def accepted *a, &b; define_hook :accepted, *a, &b; end

  end
end

