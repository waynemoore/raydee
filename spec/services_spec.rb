require_relative "../services.rb"
require_relative "../store.rb"


describe Service do

  it "should read the config from a YAML file" do
    File.should_receive(:read).with("/config/path/blegga.yml").and_return("---\n:foo: bar")
    Service.should_receive(:config_path).with("blegga.yml").and_return("/config/path/blegga.yml")
    Service.new('blegga')
  end

end


describe TwitterConnector do

  before(:each) do
    @text_store = Store.new :text
    @twitter = TwitterConnector.new
  end

  it "should update the text store" do
    status = double()
    status.stub!(:id).and_return('twitter-12345')
    status.stub!(:created_at).and_return(1345328503)

    @twitter.stub(:statuses).and_return([status])
    @twitter.update(@text_store, nil)

    text_item = @text_store.get('twitter-12345')
    text_item.should_not be_nil
    text_item[:type].should == :twitter
    text_item[:data].should == status
    text_item[:timestamp].should == Time.at(1345328503)
  end

  it "should read config from file" do
    @twitter.config.should_not be_nil
  end

end


describe InstagramConnector do

  before(:each) do
    @instagram = InstagramConnector.new
    @image_store = Store.new :image
  end

  it "should set the access token" do
    @instagram.access_token.should_not be_empty
  end

  it "should update the image store" do
    data = double()
    data.stub!(:[]).and_return(nil)
    data.stub!(:[]).with('id').and_return('instagram-12345')
    data.stub!(:[]).with('created_time').and_return('1296748524')

    @instagram.stub!(:feed).and_return([data])
    @instagram.update(nil, @image_store)

    image_item = @image_store.get('instagram-12345')
    image_item.should_not be_nil
    image_item[:type].should == :instagram
    image_item[:data].should == data
    image_item[:timestamp].should == Time.at(1296748524)
  end

end