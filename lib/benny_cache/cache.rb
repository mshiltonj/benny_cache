module BennyCache
  class Cache
    def initialize 
      @cache = {}
    end

    def fetch(key, &block)
      val = @cache[key]

      if val.nil? && block_given?
        val = block.call()
        @cache[key] = val
      end
      val
    end

    def read(key)
      @cache[key]
    end

    def write(key, val)
      @cache[key] = val
      return true
    end

    def delete(key)
      @cache.delete(key)
    end

    def clear
      @cache = {}
    end

  end
end
