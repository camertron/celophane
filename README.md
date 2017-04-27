## laminate

Turn any Ruby module into a composable decorator.

## Installation

`gem install laminate`

or put it in your Gemfile:

```ruby
gem 'laminate'
```

### Background

If you've ever worked on a large Ruby application, you've probably seen a few classes get too big. A typical example in a Rails application is the `User` model, which is a convenient place to put all the functionality for the site's logged-in experience. If allowed to grow unchecked, these bloated classes can become increasingly difficult to hold in your head at once, meaning they're more difficult to change, meaning you change them less often out of fear you'll break a fundamental part of your application.

Enter modules.

At their core, Ruby modules are just bags of methods. They're commonly used to encapsulate shared functionality, but they can also be used to separate shared groups of methods from classes that are getting too big. What this means in practical terms is a `User` model that looks something like this:

```ruby
class User < ActiveRecord::Base
  include LoginMethods
  include EmailMethods
  include RoleMethods
  ...
end
```

Each of the modules represents a cohesive group of methods that we're basically injecting into `User` when the application starts up. The upside is that now `User` contains a lot less code.

Or does it? What have we really done here? As it turns out, nothing. `User` still contains the same methods it did before. The only difference is that now the methods are spread out in different files. Logically the `User` class hasn't changed at all and we're still stuck with the same problem - it's still too large to reason about and still too scary to change.

But that's not all. The separation has now made it even more difficult for the programmer to track down potential bugs. The programmer can still call all the same methods on instances of `User` but those methods aren't actually defined in user.rb.

But that's also not all. When you include a module, you're actually adding that module to the host class or module's inheritance chain. Any _public or private_ methods in the host class will take precedence over included methods. For example, consider the following class and included module:

```ruby
module HarvestHelpers
  def harvest
    :harvest_from_helper
  end
end

class VegetableGarden
  include HarvestHelpers
  
  def harvest
    :harvest_from_garden
  end
end
```

What gets returned if I run `VegetableGarden.new.harvest`? Perhaps a bit counterintuitively, you'll get `:harvest_from_garden`. Now imagine `VegetableGarden` is a huge class with 15 included modules, any of which may define the `#harvest` method. If you define the `#harvest` method in `VegetableGarden` without realizing it's already defined, you could end up breaking your application in subtle, difficult-to-debug ways. Sure, you could `prepend` the `HarvestHelpers` module instead of `include`-ing it, but that could mean stepping on the toes of another prepended or included module. What's worse, remember that both public _and_ private methods are affected, even though your private methods are probably only designed to be used in the module in which they're defined.

### Ok, so how can this gem help?

Laminate tries to address the downsides of module inclusion by converting modules into composable decorators called layers. Layers are composable because they can be progressively applied, or laid on top of one another. For example, you could add `HarvestHelpers` progressively to an instance of `VegetableGarden`. First, we'll need to turn `HarvestHelper` and `VegetableGarden` into a layers:

```ruby
module HarvestHelpers
  include Laminate::Layer
  
  def harvest
    :harvest_from_helper
  end
end

class VegetableGarden
  include Laminate::Layer
end
```

Once that's done, we can layer `HarvestHelpers` onto instances of `VegetableGarden` whenever we want harvest functionality:

```ruby
garden = VegetableGarden.new.with_layer(HarvestHelpers)
garden.harvest
```

What's more, you can create a layer out of more than one module at a time:

```ruby
module PlantHelpers
  def dig_hole
    # dig dig
  end
end

garden = VegetableGarden.new.with_layers([HarvestHelpers, PlantHelpers])
# returns #<VegetableGarden::WithHarvestHelpersAndPlantHelpers:0x007f7f9c836da0>

garden.dig_hole
garden.harvest
```

### Sweet! How does it work?

The `garden` variable is an instance of `VegetableGarden::WithHarvestHelpers`, a class laminate dynamically created and cached for you (these dynamically created classes will be created once and reused the next time `#with_layer` is called).

`VegetableGarden::WithHarvestHelpers` forwards all _public_ methods already defined in `VegetableGarden` but none of the _private_ methods, meaning layers can define private methods without fearing those methods will be inadvertently overridden by other modules.

### What about already defined methods?

Glad you asked. If `#harvest` is already defined in `VegetableGarden`, laminate will raise a helpful error:

```ruby
VegetableGarden.new.with_layer(HarvestHelpers)

# Laminate::MethodAlreadyDefinedError: Unable to add layer:
#   `#harvest' is already defined by VegetableGarden
```

If you want the layer's method to override its ancestor's method, pass `allow_overrides: true`:

```ruby
VegetableGarden.new.with_layer(HarvestHelpers, allow_overrides: true)
```

If overrides are allowed, any method defined in `HarvestHelpers` will override the corresponding method defined in `VegetableGarden`. You should consider your use case carefully before using this rather large hammer.

## License

Licensed under the MIT license. See LICENSE for details.

## Authors

* Cameron C. Dutro: http://github.com/camertron
