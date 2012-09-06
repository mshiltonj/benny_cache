module BennyCache
  module Related
    def self.included(base) #:nodoc:
      base.send :include, BennyCache::Base

      base.extend BennyCache::ClassMethods
      unless(base.class_variable_defined? :@@benny_related_indexes)
        base.class_variable_set(:@@benny_related_indexes, [])
      end

      unless(base.class_variable_defined? :@@benny_related_methods)
        base.class_variable_set(:@@benny_related_methods, [])
      end

      if base.respond_to?(:after_save)
        base.after_save :benny_cache_clear_related
      end

      if base.respond_to?(:after_destroy)
        base.after_destroy :benny_cache_clear_related
      end
    end

    def benny_cache_clear_related
      self.class.class_variable_get(:@@benny_related_indexes).each do |key|
        local_field, klass, data_cache = key.split('/')
        local_field = local_field[1, local_field.length]
        const = benny_constantize(klass)
        id = self.send(local_field)
        const.benny_data_cache_delete(id, data_cache) if id
      end

      self.class.class_variable_get(:@@benny_related_methods).each do |key|
        local_field, klass, method_cache = key.split('/')
        local_field = local_field[1, local_field.length]
        const = benny_constantize(klass)
        id = self.send(local_field)
        const.benny_method_cache_delete(id, method_cache) if id
      end

    end
  end

  module ClassMethods

    def benny_related_index(*options)
      index_keys = options.map {|idx| idx.is_a?(Array) ? idx.map{ |jdx| "#{jdx.to_s}/:#{jdx.to_s}"}.join("/") : idx }
      self.class_variable_get(:@@benny_related_indexes).push(*index_keys)
    end

    def benny_related_method(*options)
      index_keys = options.map {|idx| idx.is_a?(Array) ? idx.map{ |jdx| "#{jdx.to_s}/:#{jdx.to_s}"}.join("/") : idx }
      self.class_variable_get(:@@benny_related_methods).push(*index_keys)
    end


  end
end
