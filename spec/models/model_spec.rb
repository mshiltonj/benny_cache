require_relative "../spec_helper"

require 'mocha_standalone'

describe BennyCache::Model do
  it "should exist" do
    BennyCache::Model.should be_true
  end

  describe " " do
    before(:each) do
      @model = ModelCacheFake.new
      @model.id = 1
      @model.other_id = 123
      @model.x = 12
      @model.y = 36
      @store = BennyCache::Cache.new
      BennyCache::Config.store=@store
    end

    it "should fetch a model by id from cache" do
      ModelCacheFake.expects(:find).with(1).returns(@model)

      rv = ModelCacheFake.benny_model_cache(1)
      rv.id.should == 1
    end

    it "should fetch a model by a lookup hash from cache" do
      arel= Object.new
      ModelCacheFake.expects(:where).with(:other_id => 123).returns(arel)
      arel.expects(:first).returns(@model)
      rv = ModelCacheFake.benny_model_cache(:other_id => 123)
      rv.id.should == 1
    end

    it "should fire the after save callback when needed" do
      ModelCacheFake.expects(:find).with(1).returns(@model)

      rv = ModelCacheFake.benny_model_cache(1)
      rv.id.should == 1
      rv.id = 2
      rv.expects(:benny_model_cache_delete)
      rv.save

    end

    it "should clear the cache when destroyed" do
      ModelCacheFake.expects(:find).with(1).returns(@model)

      rv = ModelCacheFake.benny_model_cache(1)
      rv.id.should == 1
      rv.other_id = 123

      key = 'Benny/ModelCacheFake/1'
      okey = 'Benny/ModelCacheFake/other_id/123'
      fkey = 'Benny/ModelCacheFake/x/12/y/36'

      @store.expects(:delete).with(key)
      @store.expects(:delete).with(okey)
      @store.expects(:delete).with(fkey)
      rv.destroy
    end

    it "should clear the cache when saved" do

      ModelCacheFake.expects(:find).with(1).returns(@model)

      rv = ModelCacheFake.benny_model_cache(1)
      rv.id.should == 1
      rv.other_id = 123

      key = 'Benny/ModelCacheFake/1'
      okey = 'Benny/ModelCacheFake/other_id/123'
      fkey = 'Benny/ModelCacheFake/x/12/y/36'


      @store.expects(:delete).with(key)
      @store.expects(:delete).with(okey)
      @store.expects(:delete).with(fkey)
      rv.save
    end

    it "should fetch a model by a multi-field index" do
      arel= Object.new
      ModelCacheFake.expects(:where).with(:x => 12, :y => 36).returns(arel)
      arel.expects(:first).returns(@model)
      ModelCacheFake.benny_model_cache(:x => 12, :y => 36)
    end

    it "should fetch data with a yield block" do

      stuff = @model.benny_data_cache(:stuff) do
        @model.stuff
      end

      stuff.class.should == Array
      stuff[0].should == :stuff1
    end
  end

  it "should supports custom namespaces" do
      @model = ModelCacheFakeWithNs.new
      @model.id = 1

      store = BennyCache::Cache.new
      BennyCache::Config.store=store

      ModelCacheFakeWithNs.expects(:find).with(1).returns(@model)

      rv = ModelCacheFakeWithNs.benny_model_cache(1)
      rv.id.should == 1

      ModelCacheFakeWithNs.get_benny_model_ns.should == "Benny/custom_ns"

  end
end
