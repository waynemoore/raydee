require 'sinatra'
require 'sinatra/reloader'
require_relative 'store'
require_relative 'services'
require_relative 'widgets'
require_relative 'utils'

enable :sessions

CONFIG = {
  :auto_reload => `hostname` =~ /aztec/
}

SERVICES = [TwitterConnector, InstagramConnector]
WIDGETS = [ZenBroadbandWidget]

def initialize
  also_reload path_to('store.rb')
  also_reload path_to('utils.rb')
end

get "/" do
  text_store = Store.new :text
  image_store = Store.new :images

  SERVICES.each do |service_klass|
    service_klass.new.update text_store, image_store
  end

  @info_widgets = WIDGETS.map { |klass|  klass.new }
  @social_widgets = text_store.items + image_store.items
  @config = CONFIG

  haml :index
end

get "/assets/style.sass" do
  scss :style
end

private

def path_to file
  File.join(File.absolute_path(File.dirname(__FILE__)), file)
end
