module StateFu

  # Handles dumping / loading a Machine to common interchange formats
  # (Simple ruby data structures, YAML, JSON, Marshal )
  #
  # Note this is not possible if any components have procs / lambdas
  # Which may neccessitate looking @ eg erb for failure message
  # templating
  #

  module MachineText
    attr_accessor :format

    def to_ruby
    end

  end

  module MachineToRuby

    def to_ruby
    end

  end

  class Nirvana

    attr_reader :machine, :hash, :string

    def initialize( data )
      if StateFu::Machine === data
        @machine        = data.extend        MachineToRuby
        return
      elsif String === data
        @string      = data.extend      StringToRuby
      elsif IO     === data
        @string      = data.read.extend StringToRuby
      end
    end

    def datasources
      [machine, hash, string].compact
    end

    def to_ruby()
      hash || ( datasources.unshift ).to_ruby
    end

    def to_machine()
      machine || ( datasources.unshift ).to_machine
    end

    def to_code()
      StateFu::Writer.new( to_machine )
    end

    def to_yaml
      to_ruby.to_yaml
    end

    def to_json
      to_ruby.to_json
    end

    def to_dump
      begin
        Marshal.dump( to_machine )
      rescue TypeError
        # ...
      end
    end

  end
end
