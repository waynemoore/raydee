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

    it "should raise an ArgumentError if item is nil" do
      expect { @store.put(nil) }.to raise_exception ArgumentError
    end

    it "should raise an InvalidIdError if the id is nil" do
      expect { @store.put(double({:id => nil})) }.to raise_exception InvalidIdException
    end

    it "should store and retrieve an item by id" do
      item = double({:id => "12345", :bar => 123})
      @store.put(item).should == nil
      @store.get("12345").should == item
    end

    it "should provide items in insertion order" do
      item1 = double({:id => "foo", :data => 1})
      item2 = double({:id => "bar", :data => 2})

      @store.put(item2)
      @store.put(item1)

      @store.items.should == [item2, item1]
    end

    it "should not store the same item twice" do
      item1 = double({:id => "foo", :data => 1})
      item2 = double({:id => "bar", :data => 2})

      @store.put(item1)
      @store.put(item2)
      @store.put(item1)

      @store.items.should == [item1, item2]
    end

    it "should overwrite existing items" do
      item1 = double({:id => "foo", :data => 1})
      item2 = double({:id => "bar", :data => 2})
      item3 = double({:id => "foo", :data => "blegga"})

      @store.put(item1)
      @store.put(item2)
      @store.put(item3)

      @store.items.should == [item3, item2]
    end

    it "should not allow modification of the internal list" do
      @store.items << "foo"
      @store.items.should == []
    end

  end

end
