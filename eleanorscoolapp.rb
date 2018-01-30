# myapp.rb
require 'sinatra'
require 'net/http'
require 'uri'

set :bind, '0.0.0.0'

get '/' do
  'Eleanor rulez'
end

get '/quote' do
  uri = URI(ENV["SERVICE_URL"])
  Net::HTTP.get(uri)
end

get '/ping' do
  uri = URI(ENV["PING_API_URL"])
  Net::HTTP.get(uri)
end
