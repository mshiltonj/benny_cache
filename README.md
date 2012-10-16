# BennyCache

BennyCache is a model, data and method caching library that uses the ActiveRecord API, but does not try to get in between you and
ActiveRecord. The main motivation for creating BennyCache was to make it possible to implicitly and efficiently
clear the cache of one record when changes to related records are made.

For example, suppose an Agent has a set of Items in its Inventory. We have an agent's data is populated in the cache,
and we want to change the agent's inventory, either add a new item, or update the remaining ammo of a weapon.
With BennyCache, we can update an individual Item and the Agent's inventory cache is cleared. We do not have
to load the agent into memory, and the agent's basic information remains unchanged in the cache -- only the Inventory
data for that Agent is flushed.

BennyCache uses Rails.cache if available, or you can provide your own caching engine. Otherwise, it uses an 
internal memory cache by default. The internal memory cache is meant for testing and evaluation purposes only.


### Contrasting BennyCache with other similar caching tools:

* [CacheFu](https://github.com/defunkt/cache_fu) or [Rails 3 compatible fork](https://github.com/kreetitech/cache_fu)

* [CacheMoney](https://github.com/nkallen/cache-money)

* [CacheMethod](https://github.com/seamusabshere/cache_method)

__Differences__

- BennyCache is marginally aware of ActiveRecord, but doesn't touch the internals, so it should be
forward-compatible, or as much as it can be.
- Usage of BennyCache is explicit: It doesn't try to do hide itself from the code.
- Method caching in BennyCache was a bit inspired by CacheMethod. CacheMethod is a more robust solution for method
caching, especially if you are passing complex data structures as parameters.

## Installation

Add this line to your application's Gemfile:

    gem 'benny_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install benny_cache

## Usage

BennyCache will cache three separate but related types of information.

* __Model Cache__ Model Caches are a cached representation of a model
* __Data Cache__ Data Caches are cached representation of data related to a model, but not the model itself.
* __Method Cache__ Method Caches are cached result of a call to model method.

Model, data and method caches are independent of each other. A model is cached and uncached independently
of the data cache or method cache related ot the model. You can cache a model method without
caching the model itself.

Another important concept in BennyCache is the __Related Index__ When related indexes are defined, a link is 
created between one model and another model's data or method caches. For example, when a "skill" (an instance
of the Skill class) is upgraded, the related Robot will automatically have its skills method cache cleared,
without having to directly reference a Robot model. The relationship is created by defining a method_index in
the Robot class, and a related_index in the Skill class.

### Defining the cache store

By default, BennyCache uses Rails.cache store if available. You can explicitly set the cache store by calling:

    BennyCache::Config.store = Rails.cache

The cache is expected to support the `#read`, `#write`, `#delete` and `#fetch` methods of the
`ActiveSuport::Cache::Store` interface.

If Rails.cache is not defined, and you don't explicitly initialize a cache, BennyCache uses an internal
`BennyCache::Cache` object, which is just an in-memory key-value hash. The internal cache
object is not intended for production use.


### Model Indexes

Include `BennyCache::Model` into your ActiveRecord model and declare your indexes:

    class Robot < ActiveRecord::Base
      include BennyCache::Model
      benny_model_index :user_id
    end

    class Location < ActiveRecord::Base
      include BennyCache::Model
      benny_model_index [:x, :y]
    end


Once that is done, loading item from the cache is easy:

    robot = Robot.benny_model_cache(user_id: current_user.id)

    location = Location.benny_model_cache(123) # cached by primary key
    location = Location.benny_model_cache(x: 30, y: 50) # cached by coordinates

Calling these will populate the my_model object in the cache with different keys. If you
change `location` and call `#save()` or `#destroy()`, all instances will be cleared from the cache.


### Data Indexes

A data index is a piece of data related to a specific model that is created by a block of code. Data caches
are maintained separate from the model cache itself. Data caches are useful for data about a model
that is expensive to load and/or calculate, or changes infrequently in relation to the model itself.

Data caches and model caches are independent of each other. A model cache is maintained independently
of any data caches related to the model.

To use data indexes, you must first declare a data index key. When loading the key, you also pass a block that
is used to populate the cache.

    class MyModel < ActiveRecord::Base
      include BennyCache::Model

      benny_data_index :my_data_index
    end

Then, when using the model...

    my_model.benny_data_cache(:my_data_index) {
      self.expensive_data_to_calculate()
    }

The return value of self.expensive_data_to_calculate() is used to populate the cache for the :my_data_index key.
Further calls my_model.benny_data_cache(:my_data_index) will return the cached value until the cache is cleared.
Usually, some external process will invalidate a data cache.


#### Clearing data index cache
To manually clear a data index cache for a model, you need the primary key
of the model and use a class method. You do not need to instantiate the model.

    MyModel.benny_data_cache_delete(123, :my_data_index)

If changes to one model might need to invalidate the data caches of another mother, this can be managed automatically
with the `BennyCache::Related` mixin describe below.

### Method Indexes

A method index is a cached result of a call to a model method. Like Data caches, Method caches
are created and deleted separate from the model cache itself. Also like Data caches, Method caches are useful 
for caching data about a model that is expensive to load or calculate, or changes at different intervals in
relation to the model itself.

To use method indexes, declare a method index. Method indexes use ruby method aliasing, so the
source method must be defined *before* declaring the method index.

    class MyModel < ActiveRecord::Base
      include BennyCache::Model

      def method_name # source method first
        [expensive_code]
      end
      benny_method_index :method_name # index second
    end

Arguments passed to a cached method are hashed to create a unique signature per parameter list, and the 
cached value is based on the method name and the args hash sig. In the following example:

    rv1 = agent.method_name :foo
    rv2 = agent.method_name :bar

If agent#method_name is declared as a method_index, rv1 and and rv2 will be two different cached values.

#### Local caching

When a BennyCache method index is called, benny cache keeps an model-specific copy of the cache in local memory,
so multiple calls to the same method return the same object with the same object_id.
This supports in process updates to the data.  For example:
  
    rv1 = agent.method_name #=> [:a, :b, :c]
    rv1.push :d
    rv2 = agent.method_name #=> [:a, :b, :c, :d]

    rv1.size == 4 #=> true
    rv1.object_id == rv2.object_id #=> true

This behavior works for my needs, but may not suit all users. I may add the ability to change this behavior.

I have not fully tested the benny_method_index functionality with all of the ActiveRelation's varied functionality.
Using the two together and exercising different parts of ActiveRelation may have unexpected results. However, in my
simple case, where I use basic :has_many relationships and don't use #where, #include, etc, it works the way I need
it to work.

Simple use cases should work without issue, but passing complex data structures to cached methods may
confuse BennyCache. For more robust method caching, checkout out [CacheMethod](https://github.com/seamusabshere/cache_method).


#### Clearing model index cache
Method indexes will cache data on per-args_hash basis, but clearing the cache for a model index is more of a shotgun
approach: clearing a model index cache will clear _all_ cached data for all args hashes.

To manually clear a method index cache for a model, you need the primary key of the model, the method name, and use a
class method. You do not need to instantiate the model.

    MyModel.benny_method_cache_delete(123, :method_name)

If changes to one model might need to invalidate the data caches of another mother, this can be managed
with the `BennyCache::Related` mixin.


### Related Indexes

Related indexes are used when you know that a change to one model will need to invalidate 
a data or method cache of another model. Defining a related index will make the cache invalidation automatic.

BennyCache::Related installs and after_save/after_destroy callback to clear the related data indexes of other models.

Defined the two classes like so, a class that uses BennyCache::Model with a data_index, and a class that
uses BennyCache::Related that defines a benny_related_index that points to the main class's date_index

    class MainModel < ActiveRecord::Base
      has_many :related_models

      include BennyCache::Model

      benny_data_index :my_related_items  # data cache
      benny_model_index :my_related_method # method cache

    end

    class RelatedModel < ActiveRecord::Base
      belongs_to :main_model

      include BennyCache::Related
      benny_related_index ":main_model_id/MainModel/my_related_items"
      benny_related_method ":main_model_id/MainModel/my_related_method"

    end

The benny_related_index call sets up all RelatedModel instances to clear the `:my_related_items` data index of the
MainModel instance withe a primary key of `related_model.main_model_id` whenever the RelatedModel instance is created,
updated, or deleted.

The benny_related_method call sets up all RelatedModel instances to clear the `:my_related_method` method cache data of the
MainModel instance withe a primary key of `related_model.main_model_id` whenever the RelatedModel instance is created,
updated, or deleted.

### Cache namespacing

Internally, BennyCache uses the class name of the classes using BennyCache::Model as part of the key name for
caching. Sometimes that might not be what you want, and will need to explicitly declare the namespace. This happens
when you use classes that take advantage of ActiveRecord's single table inheritance:


    class Location < ActiveRecord::Base
      include BennyCache::Model
      benny_cache_ns 'Location'
    end

    class IndustrialComplex < Location

    end

    class RecreationArea < Location

    end

By declaring the above namespace, these two calls reference the same key:

    l = Location.benny_cache_model 123
    l = RecreationArea.benny_cache_model 123


## Bugs

There are probably bugs. You can report them using the githhub [BennyCache Issue Tracker](https://github.com/mshiltonj/benny_cache/issues.



Until there is an issue tracking system, send email to
`mshiltonj@gmail.com` and put 'BennyCache' in the subject.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
