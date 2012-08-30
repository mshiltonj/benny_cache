require_relative "../spec_helper"
require_relative "../test_classes"

require 'mocha_standalone'

describe BennyCache::Model do
  it "should exist" do
    BennyCache::Model.should be_true
  end

  describe " " do
    before(:each) do
      @model = ModelCacheFake.new
      @model.id = 1
      ModelCacheFake.expects(:find).with(1).returns(@model)
    end

    it "should fetch a model by id from cache with a block" do
      rv = ModelCacheFake.benny_model_cache(1)

      rv.id.should == 1
    end

  end
end
