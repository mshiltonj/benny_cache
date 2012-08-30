module BennyCache
  class Config
    @@_store = nil

    def self.store
      return @@_store if @@_store

      if const_defined?('Rails') && Rails.cache
        @@_store = Rails.cache
      else
        @@_store =  BennyCache::Cache.new
      end

      @@_store
    end

    def self.store=(store)
      @@_store = store
    end
  end
end
