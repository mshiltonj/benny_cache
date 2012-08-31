# BennyCache

BennyCache is a model caching library that uses, but does not modify or monkey patch, the ActiveRecord API. The main
motivation for creating BennyCache was to make it possible to implicitly clear the cache of one record when a change
to another record is made.

For example, supose an Agent has a set of Items in its Inventory. If the Agent data is populated in the cache,
I need to be able to make a change to one of the Agent's items in isolation, and without loading the Agent object,
and have that change automatically clear the Agent inventory from the cache, so the full inventory will
be refreshed on the next cache request. BennyCache accomplishes this.

BennyCache uses Rails.cache if available, or uses a de

## Installation

Add this line to your application's Gemfile:

    gem 'benny_cache'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install benny_cache

## Usage

### Model Indexes

Include BennyCache::Model into your ActiveRecord model and declare your indexes:

    class MyModel < ActiveRecord::Base
      include BennyCache::Model

      belongs_to :other_model

      benny_cache_model :other_model_id, [:multi_1, :multi_1]
    end

Once that is done, loading item from the cache is easy:

    my_model = MyModel.benny_model_cache(123)
    my_model = MyModel.benny_model_cache(other_id: 456)
    my_model = MyModel.benny_model_cache(multi_1: 'abc', :multi_2: 'xyx')

Calling all three of these will populate the my_model object in the cache with three different keys. If you
change my_model and call save() or just call destroy(), all three instances will be cleared from the cache.




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
