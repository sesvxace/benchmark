#--
# Benchmark v1.1 by Solistra
# =============================================================================
# 
# Summary
# -----------------------------------------------------------------------------
#   This script provides a simple benchmarking tool similar to the Benchmark
# module present in the Ruby standard library. Essentially, this script allows
# you to run specified code and objectively determine its execution speed. This
# is primarily a scripter's tool.
# 
# Usage
# -----------------------------------------------------------------------------
#   This script is intended to be used entirely through the benchmarking method
# `SES::Benchmark.measure`. This method takes the number of iterations to run
# the passed block as an argument -- if no argument is given, the block is run
# `SES::Benchmark.iterations` times (10,000 by default, though this can be
# redefined in the configuration area or during runtime). For example, we could
# measure `Array#pop` 100,000 times like so:
# 
#     SES::Benchmark.measure(100_000) { [1, 2, 3].pop }
# 
#   The `SES::Benchmark.measure` method can also report on any number of ways
# to potentially run code -- very useful for benchmarking alternative methods
# of attaining the same result. To do so, simply pass a block that takes a
# single argument; the argument passed yields a `Reporter` instance with the
# `report` method. For example, this is how we could benchmark `Array#sort`
# versus `Array#sort!`:
# 
#     SES::Benchmark.measure do |x|
#       a = (1..100).to_a.shuffle!
#       x.report('Array#sort')  { a.sort  }
#       x.report('Array#sort!') { a.sort! }
#     end
# 
#   **NOTE:** Reports are executed in the order that they are given -- running
# the code above with the `report` calls switched would produce misleading
# results. (Labels for reports are also optional, but *highly* recommended.)
# 
#   In addition to this, you may run individual reports a different number of
# times than the other reports in a `measure` block. For instance, we could
# default to running iterations 100,000 times while running a single report
# for 200,000 like so (using the previous example):
# 
#     SES::Benchmark.iterations = 100_000
#     SES::Benchmark.measure do |x|
#       a = (1..100).to_a.shuffle!
#       x.report('Array#sort')           { a.sort  }
#       x.report('Array#sort!', 200_000) { a.sort! }
#     end
# 
# License
# -----------------------------------------------------------------------------
#   This script is made available under the terms of the MIT Expat license.
# View [this page](http://sesvxace.wordpress.com/license/) for more detailed
# information.
# 
# Installation
# -----------------------------------------------------------------------------
#   Place this script below the SES Core (v2.0) script (if you are using it) or
# the Materials header, but above all other custom scripts. This script does
# not require the SES Core (v2.0), but it is recommended.
# 
#++

# SES
# =============================================================================
# The top-level namespace for all SES scripts.
module SES
  # Benchmark
  # ===========================================================================
  # Provides benchmarking tools for measuring code performance in both real
  # time and processing time.
  module Benchmark
    # =========================================================================
    # BEGIN CONFIGURATION
    # =========================================================================
    # Determines the default number of iterations for benchmarking methods
    # present in this module. Blocks passed to the method will automatically
    # iterate this many times unless a specific iteration value is given to
    # the method as an argument.
    @iterations = 10_000
    
    # Column width of the RGSS Console. This is used for display purposes and
    # is unlikely to need modification for most users.
    WIDTH = 79
    # =========================================================================
    # END CONFIGURATION
    # =========================================================================
    class << self
      # The number of iterations to run blocks of code by default.
      # @return [FixNum]
      attr_accessor :iterations
      
      # Formatting styles for benchmark reports.
      # @return [Hash{Symbol => String}]
      attr_reader   :format
    end
    
    # Provides formatting for benchmark results. The `:footer`, `:label`, and
    # `:report` strings are run through `sprintf` with specific arguments --
    # keep this in mind if you are modifying the output formatting. Also note
    # that the `:footer` is automatically right-justified to `WIDTH` columns.
    @format = {
      header:    '---- BENCHMARK ' << '-' * (WIDTH - 15),
      footer:    'TOTAL: %f (%s seconds)',
      label:     '%s:',
      report:    "  Process: %f\n  Real:    %s seconds",
      separator: '-' * WIDTH,
    }
    
    # Reporter
    # =========================================================================
    # Provides reporting for individual benchmarks.
    class Reporter
      # Creates a new {Reporter} instance.
      # 
      # @return [Reporter] the new instance
      def initialize(iterate = SES::Benchmark.iterations)
        @iterations = iterate
        @total      = [0, 0]
      end
      
      # Runs the given block `iterate` times, measuring performance and writing
      # formatted information to standard output. This method also keeps track
      # of the total running times of all reports run on this Reporter instance
      # and returns this information.
      # 
      # @param label [String, nil] the label for this report
      # @param iterate [FixNum] number of times to iterate over the given block
      # @return [Array<Float>] the total running time of all reports
      def report(label = nil, iterate = @iterations)
        puts sprintf(Benchmark.format[:label], label) unless label.nil?
        result = Benchmark.send(:time, iterate) { yield }
        puts sprintf(Benchmark.format[:report], *result)
        @total.map!.with_index { |t, i| t += result[i] }
      end
    end
    
    # Provides formatted benchmarking results. This method must be given a
    # block in order to function. Giving any arguments to the block creates a
    # new Reporter instance which is then yielded to the block; otherwise, the
    # block is simply called `iterate` times and reported.
    # 
    # @param iterate [FixNum] number of times to iterate over the given block
    # @return [void]
    def self.measure(iterate = @iterations, &block)
      puts @format[:header]
      reporter = Reporter.new(iterate)
      result = if block.arity.nonzero?
        yield reporter
      else
        time(iterate) { yield }
      end
      puts @format[:separator] if block.arity.nonzero?
      puts sprintf(@format[:footer], *result).rjust(WIDTH)
    end
    
    class << self
      private
      # Measures the amount of processing time and real time taken for the
      # passed block to operate the given number of iterations.
      # 
      # @param iterate [FixNum] the number of times to measure the given block
      # @return [Array<Float>] array of processing times; first element is
      #   processing time, second element is real time
      def time(iterate = @iterations)
        initial = [Process.times.utime, Time.now]
        iterate.times { yield }
        [Process.times.utime, Time.now].map!.with_index do |time, index|
          time - initial[index]
        end
      end
    end
    
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      # Script metadata.
      Description = Script.new(:Benchmark, 1.1, :Solistra)
      Register.enter(Description)
    end
  end
end
