if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.adapters.define 'gem' do
    add_filter '/test/'
    add_filter '/features/'
    add_filter '/spec/'
    add_filter '/autotest/'

    add_group 'Binaries', '/bin/'
    add_group 'Libraries', '/lib/'
    add_group 'Extensions', '/ext/'
    add_group 'Vendor Libraries', '/vendor/'
  end

  SimpleCov.start :gem
end

require_relative '../lib/benny_cache'
require_relative "./test_classes"

#
# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.mock_with :mocha
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
