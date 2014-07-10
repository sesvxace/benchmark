
Benchmark v1.1 by Solistra
=============================================================================

Summary
-----------------------------------------------------------------------------
  This script provides a simple benchmarking tool similar to the Benchmark
module present in the Ruby standard library. Essentially, this script allows
you to run specified code and objectively determine its execution speed. This
is primarily a scripter's tool.

Usage
-----------------------------------------------------------------------------
  This script is intended to be used entirely through the benchmarking method
`SES::Benchmark.measure`. This method takes the number of iterations to run
the passed block as an argument -- if no argument is given, the block is run
`SES::Benchmark.iterations` times (10,000 by default, though this can be
redefined in the configuration area or during runtime). For example, we could
measure `Array#pop` 100,000 times like so:

    SES::Benchmark.measure(100_000) { [1, 2, 3].pop }

  The `SES::Benchmark.measure` method can also report on any number of ways
to potentially run code -- very useful for benchmarking alternative methods
of attaining the same result. To do so, simply pass a block that takes a
single argument; the argument passed yields a `Reporter` instance with the
`report` method. For example, this is how we could benchmark `Array#sort`
versus `Array#sort!`:

    SES::Benchmark.measure do |x|
      a = (1..100).to_a.shuffle!
      x.report('Array#sort')  { a.sort  }
      x.report('Array#sort!') { a.sort! }
    end

  **NOTE:** Reports are executed in the order that they are given -- running
the code above with the `report` calls switched would produce misleading
results. (Labels for reports are also optional, but *highly* recommended.)

  In addition to this, you may run individual reports a different number of
times than the other reports in a `measure` block. For instance, we could
default to running iterations 100,000 times while running a single report
for 200,000 like so (using the previous example):

    SES::Benchmark.iterations = 100_000
    SES::Benchmark.measure do |x|
      a = (1..100).to_a.shuffle!
      x.report('Array#sort')           { a.sort  }
      x.report('Array#sort!', 200_000) { a.sort! }
    end

License
-----------------------------------------------------------------------------
  This script is made available under the terms of the MIT Expat license.
View [this page](http://sesvxace.wordpress.com/license/) for more detailed
information.

Installation
-----------------------------------------------------------------------------
  Place this script below the SES Core (v2.0) script (if you are using it) or
the Materials header, but above all other custom scripts. This script does
not require the SES Core (v2.0), but it is recommended.

