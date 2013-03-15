require 'spec_helper'
require 'services'
require 'store'
require 'ostruct'


describe Configurable do

  it "should read the config from a YAML file" do
    File.should_receive(:read).with("/config/path/blegga.yml").and_return("---\n:foo: bar")
    Configurable.should_receive(:config_path).with("blegga.yml").and_return("/config/path/blegga.yml")
    Configurable.new('blegga')
  end

end


describe TwitterConnector do

  subject { TwitterConnector.new }

  let(:text_store)  { Store.new :text }
  let(:image_store) { Store.new :image }

  let(:text_status) {
    OpenStruct.new({
      :id => 101,
      :created_at => 1345328503,
      :user => OpenStruct.new({
        :screen_name => 'foo',
        :profile_image_url => 'url',
      }),
      :text => 'status update',
      :attrs => {
        :entities => {}
      }
    })
  }

  let(:image_status) {
    OpenStruct.new({
      :id => 101,
      :created_at => 1345328603,
      :user => OpenStruct.new({
        :screen_name => 'bar',
        :profile_image_url => 'url',
      }),
      :text => 'status update',
      :attrs => {
        :entities => {
          :media => [{
            :id => 201,
            :type => 'photo',
            :id_str => '201',
            :media_url => 'http://mediau.rl',
          }]
        }
      }
    })
  }

  let(:image_status_multi) {
    OpenStruct.new({
      :id => 101,
      :created_at => 1345328603,
      :user => OpenStruct.new({
        :screen_name => 'bar',
        :profile_image_url => 'url',
      }),
      :text => 'status update',
      :attrs => {
        :entities => {
          :media => [{
            :id => 201,
            :type => 'photo',
            :id_str => '201',
            :media_url => 'http://mediau1.rl',
          },
          {
            :id => 202,
            :type => 'photo',
            :id_str => '201',
            :media_url => 'http://mediau2.rl',
          }]
        }
      }
    })
  }

  describe ".status_to_text" do

    let(:text_item) { TwitterConnector.status_to_text(text_status) }

    it "extracts the type" do
       text_item.type.should == :twitter
    end

    it "extracts the id" do
      text_item.id.should == 101
    end

    it "extracts the timestamp" do
      text_item.timestamp.should == Time.at(1345328503)
    end

    it "extracts the user name" do
      text_item.user[:name].should == 'foo'
    end

    it "extracts the user's profile pic url" do
      text_item.user[:pic_url].should == 'url'
    end

    it "extracts the status text" do
      text_item.text.should == 'status update'
    end

  end

  describe ".entity_to_image" do

    let(:image_item) { TwitterConnector.status_to_text(image_status) }

    it "extracts the type" do
       image_item.type.should == :twitter
    end

    it "extracts the id" do
      image_item.id.should == 101
    end

    it "extracts the timestamp" do
      image_item.timestamp.should == Time.at(1345328603)
    end

    it "extracts the user name" do
      image_item.user[:name].should == 'bar'
    end

    it "extracts the user's profile pic url" do
      image_item.user[:pic_url].should == 'url'
    end

    it "extracts the image url" do
      image_item.text.should == 'status update'
    end

  end

  context "updating" do

    context "text only" do

      before(:each) do
        subject.stub(:statuses).and_return([text_status])
        subject.update(text_store, image_store)
      end

      it "adds an item to the text store" do
        text_store.should have(1).item
        text_store.get(101).should_not be_nil
      end

      it "has no impact on the image store" do
        image_store.size.should == 0
      end

    end

    context "single image" do

      before(:each) do
        subject.stub(:statuses).and_return([image_status])
        subject.update(text_store, image_store)
      end

      it "adds an item to the image store" do
        image_store.should have(1).item
        image_store.get(201).should_not be_nil
      end

      it "adds an item to the text store" do
        text_store.should have(1).item
        text_store.get(101).should_not be_nil
      end

    end

    context "multiple images" do

      before(:each) do
        subject.stub(:statuses).and_return([image_status_multi])
        subject.update(text_store, image_store)
      end

      it "adds multiple items to the image store" do
        image_store.should have(2).items
        image_store.get(201).should_not be_nil
        image_store.get(202).should_not be_nil
      end

      it "adds an item to the text store" do
        text_store.should have(1).item
        text_store.get(101).should_not be_nil
      end

    end

  end

  it "reads config from file" do
    subject.config.should_not be_nil
  end

end


describe InstagramConnector do

  subject { InstagramConnector.new }

  let(:image_store) { Store.new :image }

  let(:status) {{
    'id' => 'instagram-12345',
    'created_time' => '1296748524',
    'user' => {
      'username' => 'foo',
      'profile_picture' => 'http://profile.com/pic',
    },
    'images' => {
      'low_resolution' => {'url' => 'http://instagram.com/picture'},
    }
  }}

  it "should set the access token" do
    subject.access_token.should_not be_empty
  end

  it "should update the image store" do
    subject.stub(:feed).and_return([status])
    subject.update(nil, image_store)

    image_item = image_store.get('instagram-12345')
    image_item.should_not be_nil
  end

  describe ".status_to_image" do

    let(:image_item) { InstagramConnector.status_to_image(status) }

    it "sets the type" do
      image_item.type.should == :instagram
    end

    it "sets the data" do
      image_item.data.should == status
    end

    it "extracts the timestamp" do
      image_item.timestamp.should == Time.at(1296748524)
    end

    it "extracts the user name" do
      image_item.user[:name].should == 'foo'
    end

    it "extracts the user profile pic url" do
      image_item.user[:pic_url].should == 'http://profile.com/pic'
    end

    it "extracts the image url" do
      image_item.image_url.should == 'http://instagram.com/picture'
    end

  end

end
