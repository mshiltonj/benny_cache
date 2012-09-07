require_relative "../spec_helper"

require 'mocha_standalone'

describe BennyCache::Model do


  describe "method caching" do
    before(:each) do
      @model = ModelCacheFake.new
      @model.id = 1
      @model.other_id = 123
      @model.x = 12
      @model.y = 36
      @store = BennyCache::Cache.new
      BennyCache::Config.store=@store
    end

    it "should call the original once method if uncached" do
      @model.expects(:method_to_cache_without_benny_cache).with(:foo).returns(:stuff) # only once!
      @model.expects(:method_to_cache_without_benny_cache).with(:bar).returns(:other_stuff)

      rv = @model.method_to_cache :foo
      rv.should == :stuff
      rv = @model.method_to_cache :foo # should hit cache
      rv.should == :stuff
      rv = @model.method_to_cache :bar
      rv.should == :other_stuff

      model_base_index = "Benny/ModelCacheFake/1/method/method_to_cache"
      rv = BennyCache::Config.store.read(model_base_index)
      rv.class.should == Array
      rv.size.should == 2

      rv[0].should =~ /Benny\/ModelCacheFake\/1\/method\/method_to_cache\/args\/\w+$/
      rv[1].should =~ /Benny\/ModelCacheFake\/1\/method\/method_to_cache\/args\/\w+$/

      rv[0].should_not == rv[1]

      puts rv.inspect
    end


    it "should be able to delete the cached method data" do
      @model.expects(:method_to_cache_without_benny_cache).with(:foo).returns(:stuff) # only once!

      rv = @model.method_to_cache :foo
      rv.should == :stuff
      rv = @model.method_to_cache :foo # should hit cache
      rv.should == :stuff
      model_base_index = "Benny/ModelCacheFake/1/method/method_to_cache"
      rv = BennyCache::Config.store.read(model_base_index)
      rv.size.should == 1

      ModelCacheFake.benny_method_store_method_args_indexes_delete(@model.id, :method_to_cache)

      model_base_index = "Benny/ModelCacheFake/1/method/method_to_cache"
      rv = BennyCache::Config.store.read(model_base_index)
      rv.should be_nil
    end

    it "should use the same cache index for reorder hash params" do
      @model.expects(:method_to_cache_without_benny_cache).returns(:stuff) # only once!

      rv = @model.method_to_cache :foo => :bar, :baz => :bin
      rv.should == :stuff
      rv = @model.method_to_cache :baz => :bin, :foo => :bar # should use same key
      rv.should == :stuff
      model_base_index = "Benny/ModelCacheFake/1/method/method_to_cache"
      rv = BennyCache::Config.store.read(model_base_index)
      rv.size.should == 1
    end

  end

end
