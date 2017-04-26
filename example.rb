require 'laminate'

module ActiveRecord
  class Base
    def self.find(id)
      new(id)
    end

    attr_reader :id

    def initialize(id)
      @id = id
    end
  end
end

class Game < ActiveRecord::Base
  include Laminate::Layer

  def get_some_game_data
    :some_game_data
  end
end

module Lpis
  include Laminate::Layer

  def get_some_lpi_data
    :some_lpi_data
  end
end

module BrainAreas
  include Laminate::Layer

  def get_some_brain_area_data
    :some_brain_area_data
  end
end

game = Game.find(123).with_layer(Lpis).with_layer(BrainAreas)

puts game.id
puts game.get_some_game_data
puts game.get_some_lpi_data
puts game.get_some_brain_area_data
