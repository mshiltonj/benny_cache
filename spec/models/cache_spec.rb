require_relative "../spec_helper"
describe BennyCache::Cache do 
  it "is a class" do
    BennyCache::Cache
  end

  it "can be instantiated" do
    c = BennyCache::Cache.new
    c.should be_true
  end

  describe do 
    before(:each) do
      @c = BennyCache::Cache.new
      @key = "foo"
      @val = "bar"
    end

    methods = %w(fetch read write delete)
    methods.each do |m|
      it "should respond to #{m}" do
        @c.respond_to?(m).should be_true    
      end
    end

    it "should write and read keyed data" do
      @c.write(@key, @val)
      @c.read(@key).should == @val
    end

    it "can delete keys" do
      @c.write(@key, @val)
      @c.read(@key).should == @val
      @c.delete(@key)
      @c.read(@key).should be_nil
    end

    it "#fetch can set a nil val with a block" do
      @c.read(@key).should be_nil
      set_val = @c.fetch(@key) {
        @val
      }
      set_val.should == @val 
      @c.read(@key).should == @val
    end

    it "#clear should remove all cached data" do
      key2 = "baz"
      val2 = "bin"
      @c.write(@key, @val)
      @c.write(key2, val2)
      @c.read(@key).should == @val
      @c.read(key2).should == val2
      @c.clear
      @c.read(@key).should be_nil
      @c.read(key2).should be_nil
    end
  end
end
