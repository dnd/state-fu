require 'stringio'

module NoStdout
  module InstanceMethods

    def no_stdout ( to = StringIO.new('','r+'), &block )
      # supply an IO of your own to capture STDOUT, otherwise it's put in a StringIO
      orig_stdout  = $stdout
      $stdout      = @alt_stdout = to
      result       = yield
      $stdout      = orig_stdout
      result
    end

    def last_stdout
      return nil unless @alt_stdout
      @alt_stdout.rewind
      @alt_stdout.read
    end

  end

  # TODO - explain / remember why this has two class_eval blocks -
  # should one be an extend?
  def self.included klass
    klass.class_eval do
      include InstanceMethods
    end
    klass.extend InstanceMethods
  end

end
