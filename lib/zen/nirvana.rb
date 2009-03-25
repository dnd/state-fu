module StateFu

  # Handles dumping / loading a Koan to common interchange formats
  # (Simple ruby data structures, YAML, JSON, Marshal )
  #
  # Note this is not possible if any components have procs / lambdas
  # Which may neccessitate looking @ eg erb for failure message
  # templating
  #

  module KoanText
    attr_accessor :format

    def to_ruby
    end

  end

  module KoanToRuby

    def to_ruby
    end

  end

  class Nirvana

    attr_reader :koan, :hash, :string

    def initialize( data )
      if StateFu::Koan === data
        @koan        = data.extend        KoanToRuby
        return
      elsif String === data
        @string      = data.extend      StringToRuby
      elsif IO     === data
        @string      = data.read.extend StringToRuby
      end
    end

    def datasources
      [koan, hash, string].compact
    end

    def to_ruby()
      hash || ( datasources.unshift ).to_ruby
    end

    def to_koan()
      koan || ( datasources.unshift ).to_koan
    end

    def to_code()
      StateFu::Writer.new( to_koan )
    end

    def to_yaml
      to_ruby.to_yaml
    end

    def to_json
      to_ruby.to_json
    end

    def to_dump
      begin
        Marshal.dump( to_koan )
      rescue TypeError
        # ...
      end
    end

  end
end
