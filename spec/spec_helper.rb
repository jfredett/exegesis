require 'bundler/setup'

require 'pry'

require 'exegesis'

require 'bahia'

require 'rspec-spies'

#include helpers
Dir["./spec/helpers/*.rb"].each { |file| require file }

RSpec.configure do |config|
  config.before do
    allow_message_expectations_on_nil #because we're making proper nullclasses.
  end

  config.include(Bahia)

  config.extend(RSpec::Exegesis::DSL::Macros)
  config.include(RSpec::Exegesis::DSL::Matchers)
end
