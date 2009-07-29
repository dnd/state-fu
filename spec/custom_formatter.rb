require 'spec/runner/formatter/progress_bar_formatter'
class CustomFormatter < Spec::Runner::Formatter::ProgressBarFormatter
  def dump_pending
  end
  
  def dump_pending
    unless @pending_examples.empty?
      @output.puts
      @output.puts "Pending:"
      lpad = @pending_examples.map{|e|e[2].length}.max
      puts lpad
      @pending_examples.each do |pending_example|
        @output.puts "#{pending_example[2].strip.ljust(lpad)}  # - #{pending_example[1]}"
      end
    end
    @output.flush
  end
  
end