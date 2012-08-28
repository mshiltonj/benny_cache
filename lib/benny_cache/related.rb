module Benny
  module Related
    def self.included(base)
      base.include Benny::Base

      base.extend Benny::ClassMethods
      unless(base.class_variable_defined)
        base.class_variable_set(:@@benny_cache_related, [])
      end

      if base.respond_to?(:benny_cache_clear_related)
        base.after_save :benny_cache_clear_related
      end

      if base.respond_to?(:benny_cache_clear_related)
        base.after_delete :benny_cache_clear_related
      end
    end

    def benny_cache_clear_related
      self.class.class_variable_get(:@@benny_cache_related).each do |key|
        klass, field, data_cache = key.split('/')

        klass.constantize.kwik_e_delete_data_cache(self.send(field), data_cache)
      end
    end
  end

  module ClassMethods
    def benny_cache_related(*related_keys)
      self.class_variable_set(:@@benny_cache_related, related_keys)
    end

  end
end
