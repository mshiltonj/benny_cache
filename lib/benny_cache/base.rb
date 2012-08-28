module BennyCache
  module Base
    def self.included(base)
      base.extend(BennyCache::Base::ClassMethods)
    end

    module InstanceMethods

    end
    
    module ClassMethods

      def benny_model_ns(ns)
        self.class_variable_set(:@@BENNY_MODEL_NS, ns.to_s)
      end

      def get_benny_model_ns
         ns = self.class_variable_defined?(:@@BENNY_MODEL_NS) ? self.class_variable_get(:@@BENNY_MODEL_NS) : self.to_s
         "Benny/#{ns}"
      end
    end
  end
end
