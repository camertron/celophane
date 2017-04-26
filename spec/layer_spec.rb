require 'spec_helper'

include TestLayers

describe Laminate::Layer do
  shared_examples 'a base class' do
    it 'allows calling base methods' do
      expect(instance.base_method).to eq(:base)
    end

    it 'allows calling layer methods' do
      expect(instance.jog).to eq(:jogging)
    end
  end

  shared_examples 'a 2nd level layer class' do
    it 'allows calling 2nd level layer methods' do
      expect(instance.run).to eq(:running)
    end
  end

  shared_examples 'a 3rd level layer class' do
    it 'allows calling 3rd level layer methods' do
      expect(instance.sprint).to eq(:sprinting)
    end
  end

  context 'with an instance of the base class' do
    let(:instance) { Person.new }

    it "doesn't do any nesting for the base layer" do
      expect(instance).to be_a(Person)
    end

    it_behaves_like 'a base class'
  end

  context 'with a single layer' do
    let(:instance) { Person.new.with_layer(Runner) }

    it 'nests the new module names' do
      expect(instance).to be_a(Person::WithRunner)
    end

    it_behaves_like 'a base class'
    it_behaves_like 'a 2nd level layer class'
  end

  context 'with a second layer' do
    let(:instance) { Person.new.with_layer(Runner).with_layer(Sprinter) }

    it 'nests the new module names' do
      expect(instance).to be_a(Person::WithRunner::WithSprinter)
    end

    it_behaves_like 'a base class'
    it_behaves_like 'a 2nd level layer class'
    it_behaves_like 'a 3rd level layer class'
  end

  context 'with a combined layer' do
    let(:instance) { Person.new.with_layers([Runner, Sprinter]) }

    it 'combines the module names for the new constant name' do
      expect(instance).to be_a(Person::WithRunnerAndSprinter)
    end

    it_behaves_like 'a base class'
    it_behaves_like 'a 2nd level layer class'
    it_behaves_like 'a 3rd level layer class'
  end

  describe '#with_layer' do
    it 'raises an error if passed something other than a module' do
      expect { Person.new.with_layer('foo') }.to(
        raise_error(ArgumentError, 'layers must all be modules')
      )
    end

    it 'raises an error if a method is already defined' do
      expect { Person.new.with_layer(JogMethodCollision) }.to(
        raise_error(Laminate::MethodAlreadyDefinedError)
      )
    end

    it 'ensures overriding methods does not raise errors if explicitly asked' do
      instance = -> { Person.new.with_layer(JogMethodCollision, allow_overrides: true) }
      expect(&instance).to_not raise_error
    end

    it 'ensures overridden methods take precedence' do
      person = Person.new.with_layer(JogMethodCollision, allow_overrides: true)
      expect(person.jog).to eq(:jogging_collision)
    end
  end

  describe '#with_layers' do
    it 'includes modules in order' do
      layers = [JogMethodCollision, JogMethodCollision2]
      person = Person.new.with_layers(layers, allow_overrides: true)
      expect(person.jog).to eq(:jogging_collision2)

      layers = [JogMethodCollision2, JogMethodCollision]
      person = Person.new.with_layers(layers, allow_overrides: true)
      expect(person.jog).to eq(:jogging_collision)
    end
  end
end
