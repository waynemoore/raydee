require 'twitter'
require 'yaml'
require 'config/raydee'


class Configurable

  attr_accessor :name, :config

  def initialize(name)
    @name = name
    @config = self.class.read_config name
  end

  def self.read_config name
    path = config_path("#{name}.yml")
    YAML::load(File.read(path))
  end

  def self.config_path file_name
    File.join(CONFIG_ROOT, "services", file_name)
  end

end


class TwitterConnector < Configurable

  attr_accessor :config

  def initialize
    super "twitter"
    Twitter.configure do |config|
      config.consumer_key = @config[:consumer_key]
      config.consumer_secret = @config[:consumer_secret]
      config.oauth_token = @config[:oauth_token]
      config.oauth_token_secret = @config[:oauth_token_secret]
    end
  end

  def update(text_store, image_store)
    statuses.each do |status|
      text_store.put(status.id, {
        :type => :twitter,
        :timestamp => Time.at(status.created_at),
        :user => {
          :name => status.user.screen_name,
          :pic_url => status.user.profile_image_url,
        },
        :text => status.text,
        :data => status
      })
    end
  end

  def statuses
    Twitter.list_timeline(:slug => @config[:list], :include_entities => true)
  end

end


class InstagramConnector < Configurable

  attr_accessor :access_token

  def initialize
    super "instagram"
    @access_token = @config[:access_token]
  end

  def update(text_store, image_store)
    feed.each do |status|
      image_store.put(status['id'], {
        :type => :instagram,
        :timestamp => Time.at(status['created_time'].to_i),
        :user => {
          :name => status['user']['username'],
          :pic_url => nil,
        },
        :image_url => status['images']['low_resolution']['url'],
        :data => status
      })
    end
  end

  def feed
    response = RestClient.get("https://api.instagram.com/v1/users/self/feed?access_token=#{access_token}")
    json = JSON.load(response)
    json["data"]
  end

end
