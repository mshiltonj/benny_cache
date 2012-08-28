module BennyCache
  module Model

    def self.included(base)
      base.include BennyCache::Base
      base.extend Model::ClassMethods

      unless base.class_variable_defined? :@@BENNY_MODEL_INDEXES
        base.class_variable_set(:@@BENNY_MODEL_INDEXES, [])
      end

      unless base.class_variable_defined? :@@BENNY_DATA_INDEXES
        base.class_variable_set(:@@BENEY_DATA_INDEXES, [])
      end

      if base.respond_to? :after_save
        base.after_save :benny_model_clear_cache
      end

      if base.respond_to? :after_destroy
        base.after_destroy :benny_model_clear_cache
      end

      def benny_cache_clear
        puts "benny_model_clear_cache"
        ns = self.benny_model_ns
        key = "#{ns}/#{self.id}"
        puts "deleting key #{key}"
        Rails.cache.delete(key)
        self.class.class_variable_get(:@@BENNY_MODEL_INDEXES).each do |idx|
          key =  "#{ns}/" + idx.gsub(/:(\w+)/) { self.send($1) }
          Rails.cache.delete(key)
        end
      end

      def benny_cache_model(data_key, &block)
        full_key = self.class.benny_cache_full_key(self.id, data_key)
        Rails.cache.fetch(full_key, &block)
      end
    end

    module ClassMethods

      def benny_data_cache_delete(model_id, data_key)
        full_key = self.benny_cache_full_key(model_id, data_key)
        Rails.cache.delete(full_key)
      end

      def benny_cache_full_data_key(model_id, data_key)
        raise "undefined cache data key #{data_key}" unless self.class_variable_get(:@@BENNY_MODEL_DATA_KEYS).include?(data_key.to_s)
        ns = self.benny_model_ns
        full_key = "#{ns}/#{model_id}/data/#{data_key.to_s}"
      end

      def benny_model_key(*options)
        self.class_variable_set(:@@BENNY_MODEL_INDEXES, options.flatten)
      end

      def benny_data_index(*options)
        self.class_variable_set(:@@BENNY_DATA_INDEXES, options.flatten)
      end

      def set_benny_model_ns(ns)
        self.class_variable_set(:@@BENNY_MODEL_NS, ns.to_s)
      end

      def benny_model_ns
         self.class_variable_defined?(:@@BENNY_MODEL_NS) ? self.class_variable_get(:@@BENNY_MODEL_NS) : self.to_s
      end

      def model_cache(options)
        ns = self.benny_model_ns

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

          Rails.cache.fetch("#{ns}/#{key}") {
            self.where(options).first
          }
        else # should be a number/id
          Rails.cache.fetch("#{ns}/#{options}") {
            self.find(options)
          }
        end
      end
    end
  end
end
