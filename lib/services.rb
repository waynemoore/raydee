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

  # TODO: refactor, this method is doing too much
  def update(text_store, image_store)
    statuses.each do |status|
      text = self.class.status_to_text(status)
      text_store.put(text)

      entities = status.attrs[:entities][:media]
      unless entities.nil?
        entities.each do |entity|
          if entity[:type] == "photo"
            image = self.class.entity_to_image(status, entity)
            image_store.put(image)
          end
        end
      end
    end
  end

  def statuses
    Twitter.list_timeline(:slug => @config[:list], :include_entities => true)
  end

  def self.status_to_text(status)
    timestamp = Time.at(status.created_at)
    user = {
      :name => status.user.screen_name,
      :pic_url => status.user.profile_image_url,
    }

    Text.new status.id, :twitter, timestamp, user, status.text, status
  end

  def self.entity_to_image(status, entity)
    id = entity[:id]
    timestamp = Time.at(status.created_at)
    image_url = "#{entity[:media_url]}:thumb"
    user = {
      :name => status.user.screen_name,
      :pic_url => status.user.profile_image_url,
    }

    Image.new(id, :twitter, timestamp, user, image_url, entity)
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
      image = self.class.status_to_image(status)
      image_store.put(image)
    end
  end

  def feed
    response = RestClient.get("https://api.instagram.com/v1/users/self/feed?access_token=#{access_token}")
    json = JSON.load(response)
    json["data"]
  end

  def self.status_to_image(status)
    id = status['id']
    timestamp = Time.at(status['created_time'].to_i)
    image_url = status['images']['low_resolution']['url']
    user = {
      :name => status['user']['username'],
      :pic_url => status['user']['profile_picture'],
    }

    Image.new(id, :instagram, timestamp, user, image_url, status)
  end

end


class Image

  attr_accessor :id, :type, :timestamp, :user, :image_url, :data

  def initialize id, type, timestamp, user, image_url, data
    @id = id
    @type = type
    @timestamp = timestamp
    @user = user
    @image_url = image_url
    @data = data
  end

end


class Text

  attr_accessor :id, :type, :timestamp, :user, :text, :data

  def initialize id, type, timestamp, user, text, data
    @id = id
    @type = type
    @timestamp = timestamp
    @user = user
    @text = text
    @data = data
  end

end