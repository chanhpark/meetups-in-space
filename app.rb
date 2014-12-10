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

def member?(user_id, meetup_id)
  if signed_in?
    !Rsvp.where(["user_id = ? AND meetup_id = ?", user_id, meetup_id]).empty?
  end
end

get '/' do
  @meetups = Meetup.all
  erb :index
end

get '/meetups/:id' do
  @meetups = Meetup.find_by_id(params[:id])
  @attendees = @meetups.users

  erb :meetups
end

post '/meetups/:id' do
  @user_id = current_user[:id]
  @meetup_id = params[:id]
  if params[:leave]
    remove_user = Rsvp.where('user_id = ? AND meetup_id = ?', @user_id, @meetup_id).first
    remove_user.destroy
  else params[:join]
  @rsvp = Rsvp.create(user_id: @user_id, meetup_id: @meetup_id)
  end
  redirect "/meetups/#{@meetup_id}"
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
