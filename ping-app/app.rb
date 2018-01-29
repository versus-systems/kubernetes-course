# app.rb
require 'sinatra'

set :bind, '0.0.0.0'

# get /ping
# get /pong

get '/:name' do
  if (params[:name] || "ping") == "ping"
    "POING"
  else
    "PING"
  end
end
