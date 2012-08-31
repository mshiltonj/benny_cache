require_relative "../spec_helper"

require 'mocha_standalone'

describe BennyCache::Config do
  it "should exist" do
    BennyCache::Config.should be_true
  end

  it "should default to a BennyCache::Cache" do
    BennyCache::Config.store = nil
    BennyCache::Config.store.class.should == BennyCache::Cache
  end

end
