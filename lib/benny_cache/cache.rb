module BennyCache
  class Cache
    def initialize 
      @cache = {}
    end

    def fetch(key, options = nil, &block)
      val = @cache[key]

      if val.nil? && block_given?
        val = block.call()
        @cache[key] = val
      end

      begin
        val = val.dup unless val.nil?
      rescue TypeError
        #okay
      end
      val

    end

    def read(key, options = nil)
      val = @cache[key]
      val = val.dup unless val.nil?

    end

    def write(key, val, options = nil)
      @cache[key] = val.dup
      return true
    end

    def delete(key, options = nil)
      @cache.delete(key)
    end

    def clear(options = nil)
      @cache = {}
    end

  end
end
