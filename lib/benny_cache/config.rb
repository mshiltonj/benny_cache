module BennyCache
  class Config
    @@_store

    def self.store
      @@_store ||= Rails.cache
    end

    def self.store=(store)
      @@_store = store
    end
  end
end
