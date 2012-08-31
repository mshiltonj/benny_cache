# BennyCache

BennyCache is a model caching library that uses, but does not modify or monkey patch, the ActiveRecord API. The main
motivation for creating BennyCache was to make it possible to implicitly clear the cache of one record when a change
to another record is made.

For example, suppose an Agent has a set of Items in its Inventory. If the Agent data is populated in the cache,
I need to be able to make a change to one of the Agent's items in isolation, and without loading the Agent object,
and have that change automatically clear the Agent inventory from the cache, so the full inventory will
be refreshed on the next cache request. BennyCache accomplishes this.

BennyCache uses Rails.cache if available, or uses an internal memory cache by default. The internal memory cache
is meaning for testing and evaluation purposes only.

## Installation

Add this line to your application's Gemfile:

    gem 'benny_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install benny_cache

## Usage

BennyCache will cache two separate but related types of information.

* ''Model Cache'' Model Caches are a cached representation of a model
* ''Data Cache'' Data Caches are cached representation of data related to a model, but not the model itself.

### Defining the cache store

By default, BennyCache uses the store at Rails.cache if available. You can explicitly set the cache store by calling:

    BennyCache::Config.store = Rails.cache

The cache is expected to support the #read, #write, #delete and #fetch methods of the
ActiveSuport::Cache::Store interface.

If Rails.cache is not defined, and you don't explicitly initialize a cache, BennyCache uses an internal
BennyCache::Cache object, which is just an in-memory key-value hash.


### Model Indexes

Include BennyCache::Model into your ActiveRecord model and declare your indexes:

    class MyModel < ActiveRecord::Base
      include BennyCache::Model

      belongs_to :other_model

      benny_model_index :other_model_id, [:multi_1, :multi_1]
    end

Once that is done, loading item from the cache is easy:

    my_model = MyModel.benny_model_cache(123)
    my_model = MyModel.benny_model_cache(other_id: 456)
    my_model = MyModel.benny_model_cache(multi_1: 'abc', :multi_2: 'xyx')

Calling all three of these will populate the my_model object in the cache with three different keys. If you
change my_model and call save() or just call destroy(), all three instances will be cleared from the cache.


### Data Indexes

A data index is a piece of data related to a specific model that is created by a block of code. Data caches
are created and deleted separate from the model cache itself. Data caches are useful for data about a model
that is expensive to load and/or calculate, or changes infrequently in relation to the model itself.

Data caches and model caches are independent of each other. A model is cached and uncached independently
of the data cache related ot the model.  This is similar to memoizing a method.

To use data indexes, you must first declare a date index key. When loading the key, you also pass a block that
is used to populate the cache.

  class MyModel << ActiveRecord::Base
    include BennyCache::Model

    benny_data_index :my_data_index
  end

Then, when using the model...

  my_model.benny_data_cache(:my_data_index) {
    self.expensive_data_to_calculate()
  }

The return value of self.expensive_data_to_calculate() is used to populate the cache for the :my_data_index key.
Further calls my_model.benny_data_cache(:my_data_index) will return the cached value until the cache is cleared.
Usually, some external proccess will invalidate a data cache. Internally, the :my_data_index value is
associated with the primary_key value of the model.


#### Clearing data index cache
To manually clear a data index cache for a model, you do not need to instantiate the model. You need the primary key
of the model and use a class method:

  MyModel.benny_data_cache_delete(123, :my_data_index)

However, if changes to one model might need to invalidate the data caches of another mother, this can be managed
with the BennyCache::Related mixin.

### Related Indexes

Related indexes are used when you know that a change to one model will need to invalidate a data change of another
model, likely a model of a different class. Defining a related index with make the cache invalidation automatic.

BennyCache::Related installs and after_save/after_destroy callback to clear the related data indexes of other models.


Defined the two classes like so, a class that uses BennyCache::Model with a data_index, and a class that
uses BennyCache::Related that defines a benny_related_index that points to the main class's date_index

    class MainModel < ActiveRecord::Base
      has_many :related_models

      include BennyCache::Model

      benny_data_index :my_related_items

    end

    class RelatedModel < ActiveRecord::Base
      belongs_to :main_model

      include BennyCache::Related
      benny_related_index ":main_model_id/MainModel/my_related_items"

    end

The benny_related_index call sets up all RelatedModel instances to clear the :my_related_items data_index of the
MainModel instance withe a primary key of related_model.main_model_id whenever the RelatedModel instance is created,
updated, or deleted.


### Cache namespacing

Internally, BennyCache using the class name of the classes using BennyCache::Model as part of the key name for
caching. Sometimes that might not be what you want, and will need to explicitly declare the namespace. This happens
when you use classes that take advantage of ActiveRecord's single table inheritance


  class Location < ActiveRecord::Base
    include BennyCache::Model
    benny_cache_ns 'Location'
  end

  class IndustrialComplex < Location

  end

  class RecreationArea < Location

  end

By declaring the namespace this calls reference the keys:

  l = Location.benny_cache_model 123
  l = RecreationArea.benny_cache_model 123

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
