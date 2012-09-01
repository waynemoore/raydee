$:.unshift File.join(File.absolute_path(File.dirname(__FILE__)), "lib")

require 'sinatra'
require 'sinatra/reloader'
require 'store'
require 'services'
require 'widgets'
require 'instagram_utils'
require 'config/raydee'
require 'utils'

enable :sessions

CONFIG = {
  :auto_reload => `hostname` =~ /aztec/
}

Dir.glob(File.join(APP_ROOT, "lib", "*.rb")).map {|fn| also_reload fn}

get "/" do
  all_services = load_services

  text_store = Store.new :text
  image_store = Store.new :images

  all_services[:services].each do |service_klass|
    service_klass.new.update text_store, image_store
  end

  @info_widgets = all_services[:widgets].map { |klass|  klass.new }
  @social_widgets = text_store.items + image_store.items
  @config = CONFIG

  haml :index
end

get "/assets/style.sass" do
  scss :style
end
