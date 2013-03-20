require 'bundler/setup'

require 'pry'

require 'exegesis'

require 'bahia'

require 'rspec-spies'

#include helpers
Dir["./spec/helpers/*.rb"].each { |file| require file }

#include shared examples
Dir["./spec/shared/*_examples.rb"].each { |file| require file }

RSpec.configure do |config|
  config.before do
    allow_message_expectations_on_nil
  end

  config.after do
    SourceFile.clear_registry!
    Directory.clear_registry!
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.include(Bahia)

  config.extend(RSpec::Exegesis::DSL::Macros)
  config.include(RSpec::Exegesis::DSL::Matchers)
end

class RSpec::Mocks::Mock
  def inspect
    "double(#{@name.inspect})"
  end
end
