require 'json'

class LifelogController < ApplicationController
  before_action :authenticate_user!

  def index
    client = OAuth2::Client.new(ENV['LIFELOG_CLIENT_ID'], ENV['LIFELOG_CLIENT_SECRET'], site: 'https://platform.lifelog.sonymobile.com/', authorize_url: '/oauth/2/authorize', token_url: '/oauth/2/token')
    oauth_url = client.auth_code.authorize_url(redirect_uri: 'https://actowatch.herokuapps.com/oauth/callback', scope: 'lifelog.activities.read')
    redirect_to oauth_url
  end

  def callback
    client = OAuth2::Client.new(ENV['LIFELOG_CLIENT_ID'], ENV['LIFELOG_CLIENT_SECRET'], site: 'https://platform.lifelog.sonymobile.com/', authorize_url: '/oauth/2/authorize', token_url: '/oauth/2/token')
    token = client.auth_code.get_token(params[:code])
    current_user.lifelog_oauth_token = token.to_hash.to_json
    current_user.save
  end
end
