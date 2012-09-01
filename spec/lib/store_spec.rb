require 'spec_helper'
require 'store'


describe Store do

  it "should create a new store with a name and empty list" do
    store = Store.new :foo
    store.name.should == :foo
    store.items.should be_empty
  end

  context "instance" do

    before(:each) do
      @store = Store.new :foo
    end

    it "should raise an error if nil key is used" do
      expect { @store.put(nil, {}) }.to raise_exception InvalidIdException
    end

    it "should store and retrieve an item by id" do
      @store.put("12345", {:bar => 123}).should == nil
      @store.get("12345").should == {:bar => 123}
    end

    it "should provide items in insertion order" do
      @store.put("foo", {:foo => 1})
      @store.put("bar", {:bar => 2})
      @store.items.should == [{:foo => 1}, {:bar => 2}]
    end

    it "should not store the same item twice" do
      @store.put("foo", {:foo => 1})
      @store.put("bar", {:bar => 2})
      @store.put("foo", {:foo => 1})
      @store.items.should == [{:foo => 1}, {:bar => 2}]
    end

    it "should overwrite existing items" do
      @store.put("foo", {:foo => 1})
      @store.put("bar", {:bar => 2})
      @store.put("foo", {:blegga => 1})
      @store.items.should == [{:blegga => 1}, {:bar => 2}]
    end

    it "should not allow modification of the internal list" do
      @store.items << "foo"
      @store.items.should == []
    end

  end

end
