module BennyCache
  module Base
    def self.included(base) #:nodoc:
      base.extend(BennyCache::Base::ClassMethods)
    end

    def benny_constantize(string) #:nodoc:
      if string.respond_to?(:constantize)
        # use ActiveSupport directly if possible
        string.constantize
      else
        names = string.split('::')
        names.shift if names.empty? || names.first.empty?
        constant = Object
        names.each do |name|
          constant = constant.const_get(name)
        end
        constant
      end
    end

    
    module ClassMethods

      def benny_model_ns(ns)
        self.class_variable_set(:@@BENNY_MODEL_NS, ns.to_s)
      end

      def get_benny_model_ns #:nodoc:
         ns = self.class_variable_defined?(:@@BENNY_MODEL_NS) ? self.class_variable_get(:@@BENNY_MODEL_NS) : self.to_s
         "Benny/#{ns}"
      end

    end
  end
end
