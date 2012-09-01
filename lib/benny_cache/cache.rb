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
      val
    end

    def read(key, options = nil)
      @cache[key]
    end

    def write(key, val, options = nil)
      @cache[key] = val
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
