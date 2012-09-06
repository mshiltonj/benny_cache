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
      BennyCache::Config.store.expects(:delete).with('Benny/ModelCacheFake/456/method/method_to_cache')

      @related.save
    end

    it "should clear a cache key" do
      @related = RelatedCacheFake.new
      @related.model_id = '456'
      BennyCache::Config.store.expects(:delete).with('Benny/ModelCacheFake/456/method/method_to_cache')
      BennyCache::Config.store.expects(:delete).with('Benny/ModelCacheFake/456/data/stuff')
      @related.save
    end

    it "should clear a related method when saved" do

      @model = ModelCacheFake.new

      @model.id = 456
      @model.method_to_cache :foo
      @model.method_to_cache :bar

      @related = RelatedCacheFake.new
      @related.model_id = '456'

      model_base_index = "Benny/ModelCacheFake/456/method/method_to_cache"
      rv = BennyCache::Config.store.read(model_base_index)
      rv.class.should == Array
      rv.size.should == 2

      @related.save

      rv = BennyCache::Config.store.read(model_base_index)
      rv.should be_nil

    end
  end

end
