#--
# Benchmark v1.0 by Solistra
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
#   TODO: Document usage of the script.
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
module SES
  # ===========================================================================
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
      attr_accessor :iterations
      attr_reader   :format
    end
    
    @format = {
      :header    => '---- BENCHMARK ' << '-' * (WIDTH - 15),
      :footer    => 'TOTAL: %f (%s seconds)',
      :label     => '%s:',
      :report    => "  Process: %f\n  Real: %s seconds",
      :separator => '-' * WIDTH,
    }
    
    # =========================================================================
    # Reporter
    # =========================================================================
    # Provides reporting for individual benchmarks.
    class Reporter
      def initialize() @total = [0, 0] end
      
      # Runs the given block `iterate` times, measuring performance and writing
      # formatted information to standard output. This method also keeps track
      # of the total running times of all reports run on this Reporter instance
      # (and returns this information).
      def report(label = nil, iterate = SES::Benchmark.iterations)
        puts sprintf(Benchmark.format[:label], label) unless label.nil?
        result = Benchmark.time(iterate) { yield }
        puts sprintf(Benchmark.format[:report], *result)
        @total.map!.with_index { |t, i| t += result[i] }
      end
    end
    
    # Provides formatted benchmarking results. This method must be given a
    # block in order to function. Giving any arguments to the block creates a
    # new Reporter instance which is then yielded to the block; otherwise, the
    # block is simply called `iterate` times and reported.
    def self.measure(iterate = @iterations, &block)
      puts @format[:header]
      reporter = Reporter.new
      result = if block.arity.nonzero?
        yield reporter
      else time(iterate) { yield } end
      puts @format[:separator] if block.arity.nonzero?
      puts sprintf(@format[:footer], *result).rjust(WIDTH)
    end
    
    # Measures the amount of processing time and real time taken for the passed
    # block to operate the given number of iterations. Returns an array with
    # the following elements:
    #     [user processing time, real time]
    def self.time(iterate = @iterations)
      initial = [Process.times.utime, Time.now]
      iterate.times { yield }
      [Process.times.utime, Time.now].map!.with_index do |time, index|
        time - initial[index]
      end
    end
    
    # Register this script with the SES Core if it exists.
    if SES.const_defined?(:Register)
      Description = Script.new(:Benchmark, 1.0)
      Register.enter(Description)
    end
  end
end