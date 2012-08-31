require_relative "../spec_helper"

require 'mocha_standalone'

describe BennyCache::Related do
  it "should exist" do
    BennyCache::Related.should be_true
  end

  describe "" do
    before(:each) do
      BennyCache::Config.store=BennyCache::Cache.new
    end

    it "should clear a related index when saved" do
      @related = RelatedCacheFake.new
      @related.model_id = '456'
      @related.expects(:benny_cache_clear_related)
      @related.save
    end

    it "should try to clear a related index when saved" do
      @related = RelatedCacheFake.new
      @related.model_id = '456'
      ModelCacheFake.expects(:benny_data_cache_delete).with('456', 'stuff')
      @related.save
    end

    it "should clear a cache key" do
      @related = RelatedCacheFake.new
      @related.model_id = '456'
      BennyCache::Config.store.expects(:delete).with('Benny/ModelCacheFake/456/data/stuff')
      @related.save
    end
  end

end
