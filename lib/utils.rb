require 'rest_client'

get "/util/instagram/oauth" do
  if params.has_key? "code"
    oauth_params = {
      "client_id" => client_id,
      "client_secret" => secret_id,
      "grant_type" => "authorization_code",
      "redirect_uri" => redirect_uri,
      "code" => params["code"],
    }
    @access_token = RestClient.post("https://api.instagram.com/oauth/access_token", oauth_params)
  end
  haml :"util/instagram_oauth"
end

post "/util/instagram/oauth" do
  (session[:client_info] ||= {}).tap do |client|
    params.each do |key, val|
      client[key.to_sym] = val
    end
  end
  AUTH_URL = "https://api.instagram.com/oauth/authorize/?client_id=#{client_id}&redirect_uri=#{redirect_uri}&response_type=code"
  redirect AUTH_URL
end


private

def client_id
  session[:client_info][:client_id]
end

def secret_id
  session[:client_info][:client_secret]
end

def redirect_uri
  session[:client_info][:redirect_uri]
end
