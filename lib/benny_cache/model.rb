module BennyCache
  module Model

    def self.included(base)
      base.instance_eval {
        include BennyCache::Base
      }

      base.extend BennyCache::Model::ClassMethods

      unless base.class_variable_defined? :@@BENNY_MODEL_INDEXES
        base.class_variable_set(:@@BENNY_MODEL_INDEXES, [])
      end

      unless base.class_variable_defined? :@@BENNY_DATA_INDEXES
        base.class_variable_set(:@@BENNY_DATA_INDEXES, [])
      end

      if base.respond_to? :after_save
        base.after_save :benny_model_cache_delete
      end

      if base.respond_to? :after_destroy
        base.after_destroy :benny_model_cache_delete
      end

      def benny_model_cache_delete
        puts "benny_model_cache_delete"
        ns = self.class.get_benny_model_ns
        key = "#{ns}/#{self.id}"
        puts "deleting key #{key}"

        BennyCache::Config.store.delete(key)
        self.class.class_variable_get(:@@BENNY_MODEL_INDEXES).each do |idx|

          if idx.is_a?(Symbol)
            key =  "#{ns}/#{idx}/" + idx.to_s.gsub(/(\w+)/) { self.send($1) }
          elsif idx.is_a?(String)
            key =  "#{ns}/" +  idx.to_s.gsub(/:(\w+)/) { "#{self.send($1) }" }
          end

          BennyCache::Config.store.delete(key)
        end
      end

      def benny_data_cache(data_index, &block)
        full_index = self.class.benny_data_cache_full_index(self.id, data_index)
        BennyCache::Config.store.fetch(full_index, &block)
      end
    end

    module ClassMethods

      def benny_data_cache_delete(model_id, data_index) # :nodoc:
        full_index = self.benny_data_cache_full_index(model_id, data_index)
        puts "deleting full index key  #{full_index}"
        BennyCache::Config.store.delete(full_index)
      end

      def benny_data_cache_full_index(model_id, data_index) # :nodoc:
        raise "undefined cache data key '#{data_index}'" unless self.class_variable_get(:@@BENNY_DATA_INDEXES).include?(data_index.to_s)
        ns = self.get_benny_model_ns
        full_index = "#{ns}/#{model_id}/data/#{data_index.to_s}"
      end

      ##
      # Declares one or more caching indexes for instances of this class.
      # You do not have to declare an :id index, but if you will be referencing or loading
      # models by other indexes, declare them here.
      #
      # Explicit declarations are needed so BennyCache knows which cache keys to clear
      # on a relevant change.
      #
      # Valid options are symbols of other methods, or for multiple-field indexes, an array
      # of :symbols
      #  class Agent
      #    benny_model_index :user_id
      #    # internally works like Agent.where(:user_id => user_id ).first when referenced
      #  end
      #
      # or
      #
      #  class Location
      #    benny_model_index [:x, :y]
      #    # internally works like Locaion.where(:x => x, :y => y ).first when referenced
      #  end
      #
      # You can include many indexes in the declaration:
      #
      #  class Foo
      #    benny_model_index :bar, :baz, [:zip, :zap]
      #  end

      def benny_model_index(*options)
        index_keys = options.map {|idx| idx.is_a?(Array) ? idx.map{ |jdx| "#{jdx.to_s}/:#{jdx.to_s}"}.join("/") : idx }
        self.class_variable_get(:@@BENNY_MODEL_INDEXES).push(*index_keys)
      end

      def benny_data_index(*options)
        self.class_variable_get(:@@BENNY_DATA_INDEXES).push(*(options.map(&:to_s)))
      end

      ##
      # Retrieves a model from the cache. If the model is no in the cache, BennyCache will load it from the database
      # and store in the cache.
      #
      #  agent = Agent.benny_model_cache(1)
      #
      # If the agent with id of 1 is not in the cache, it will make an ActiveRecord call to popuplate the cache,
      # and return the model, like so:
      #   Agent.find(1)
      #
      # If you have declared separate data indexes, you can pass a hash and and BennyCache will use
      # ActiveRelation#where to populate the hash
      #
      #   Agent.benny_model_cache(:user_id => 999)
      #
      # To populate cache, BennyCache will call
      #
      #  Agent.where(:user_id => 999)
      #
      def benny_model_cache(options)
        ns = self.get_benny_model_ns

        if options.is_a?(Hash)
          key_format = []
          key = []
          options.keys.sort.each do  |k|
            key_format << "#{k.to_s}/:#{k.to_s}"
            key << "#{k.to_s}/#{options[k].to_s}"
          end

          key = key.join('/')

          key_format = key_format.join('/')

          raise "undefined cache key format #{ns}/#{key_format}" unless self.class_variable_get(:@@BENNY_MODEL_INDEXES).include?(key_format)

          BennyCache::Config.store.fetch("#{ns}/#{key}") {
            self.where(options).first
          }
        else # should be a number/id
          BennyCache::Config.store.fetch("#{ns}/#{options}") {
            self.find(options)
          }
        end
      end
    end
  end
end
