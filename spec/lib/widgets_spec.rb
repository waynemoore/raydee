require 'spec_helper'
require 'widgets'


describe ZenBroadbandWidget do

  before(:each) do
    config = {
      :username => "foo",
      :password => "bar",
    }
    ZenBroadbandWidget.stub!(:read_config).and_return(config)
  end

  it "should read username and password from config" do
    zen = ZenBroadbandWidget.new
    zen.config[:username].should == "foo"
    zen.config[:password].should == "bar"
  end

end
