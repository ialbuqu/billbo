# encoding: UTF-8

Bundler.require

require 'bundler/setup'
require 'sinatra'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'carrierwave'
require 'carrierwave-google_drive'
require 'carrierwave/mongoid'
require 'pony'

require './functions'

Dir.glob("./{config/initializers,controllers,models,helpers}/**/*.rb").each do |file|
  require file
end

configure do
  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :expire_after => 2592000, # In seconds
                             :secret => 'change_me'
end

before do
  setup_locale
  setup_user
end
