# frozen_string_literal: true

if ENV['MUTANT']
  RSpec.configure do |config|
    config.around(:each) do |example|
      Timeout.timeout(1, &example)
    end
  end
end
