require 'pry-byebug'
require 'laminate'
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
    include Laminate::Layer

    def jog
      :jogging
    end
  end

  module JogMethodCollision
    include Laminate::Layer

    def jog
      :jogging_collision
    end
  end

  module JogMethodCollision2
    include Laminate::Layer

    def jog
      :jogging_collision2
    end
  end

  module Runner
    include Laminate::Layer

    def run
      :running
    end
  end

  module Sprinter
    include Laminate::Layer

    def sprint
      :sprinting
    end
  end
end
