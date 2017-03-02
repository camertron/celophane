require 'pry-byebug'
require 'celophane'
require 'rspec'

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true
end

module TestLayers
  class Base
    def base_method
      :base
    end
  end

  class Person < Base
    include Celophane::Layer

    def jog
      :jogging
    end
  end

  module Runner
    include Celophane::Layer

    def run
      :running
    end
  end

  module Sprinter
    include Celophane::Layer

    def sprint
      :sprinting
    end
  end
end
