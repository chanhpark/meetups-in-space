require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  @meetups = Meetup.all
  erb :index
end

get '/meetups/:id' do
  @meetups = Meetup.find_by(id: params[:id])
  @attendees = @meetups.users
  @messages = Message.all
  erb :meetups
end

post "/meetups/:id/join" do
  @user_id = current_user[:id]
  @meetup_id = params[:id]
  @join = Rsvp.create(user_id: @user_id, meetup_id: @meetup_id)
  flash[:notice] = 'You successfully joined this meetup!'
  redirect "/meetups/#{@meetup_id}"
end

post "/meetups/:id/leave" do
  @user_id = current_user[:id]
  @meetup_id = params[:id]
  remove_user = Rsvp.find_by(user_id: @user_id, meetup_id: @meetup_id)
  remove_user.destroy
  flash[:notice] = 'You successfully left this meetup.'
  redirect "/meetups/#{@meetup_id}"
end

post "/add_message" do
  Message.create(message: params[:message], user_id: current_user[:id], meetup_id: params[:meetup])
  flash[:notice] = 'Your Meetup thanks you for the update!'
  redirect "/meetups/#{params[:meetup]}"
end


get '/create_new' do

  erb :create_new
end

post '/create_new' do
  @name = params[:name]
  @description = params[:description]
  @location = params[:location]
  @meetup = Meetup.create(name: @name, description: @description, location: @location)

  if @name.empty?
    flash[:notice] = "Please insert a name for the meetup"
    redirect "/create_new"
  elsif @description.empty?
    flash[:notice] = "Please insert a description for the meet"
    redirect "/create_new"
  elsif @location.empty?
    flash[:notice] = "Please insert a location"
    redirect "/create_new"
  else
    flash[:notice] = "You successfully created a new meetup!"
    redirect "/meetups/#{@meetup[:id]}"
  end
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
