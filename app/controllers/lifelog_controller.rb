require 'json'
require 'date'

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

  def activities
    client = OAuth2::Client.new(ENV['LIFELOG_CLIENT_ID'], ENV['LIFELOG_CLIENT_SECRET'], site: 'https://platform.lifelog.sonymobile.com/', authorize_url: '/oauth/2/authorize', token_url: '/oauth/2/token')
    token = OAuth2::AccessToken.from_hash(client, JSON.parse(current_user.lifelog_oauth_token))
    if token.expired?
      token = token.refresh!
      currenc_user.lifelog_oauth_token = token.to_hash.to_json
      current_user.save
    end
    res = token.get('/v1/users/me/activities')
    durations = JSON.parse(res.response.body)['result'].map do |act|
      startTime = DateTime.parse(act['startTime'])
      endTime = DateTime.parse(act['endTime'])
      endTime - startTime
    end
    seconds = (durations.inject(:+) * 86400.0).to_f
    render json: {"seconds" => seconds}
  end
end
