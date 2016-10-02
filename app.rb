require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'sinatra/partial'
require 'escape_utils'
require 'sinatra/basic_auth'
require 'sinatra/content_for'

if development?
  require 'sinatra/reloader'
  also_reload './config/config.rb'
  also_reload './models.rb'
end

require './config/config.rb'
require './models.rb'

# Filters

before '/' do
  session[:order] = (params[:order] || session[:order] || 'score')
  if session[:order] == 'recent'
    @dm_order = [:created_at.desc]
  else
    session[:order] = 'score'
    @dm_order = [:vote_score.desc, :created_at.asc]
  end
  redirect to '/#suggestions' if params[:order]
end

# Controllers

get '/' do
  if session[:order] == 'recent'
    @entries = Entry.all(order: @dm_order)
  else
    @entries = Entry.all(:vote_score.gte => 0, order: @dm_order)
    @buried_entries = Entry.all(:vote_score.lt => 0, order: @dm_order)
  end
  erb :index
end

post '/create_entry' do
  entry = Entry.create(text: EscapeUtils.escape_html(params[:suggestion]))
  redirect back unless entry.saved?

  entry.vote(request.ip)
  redirect to "/#suggestion-#{entry.id}"
end

post '/vote' do
  entry = Entry.get!(params[:entry_id]) rescue halt(404)
  entry.vote(request.ip, params[:up] != 'false')

  partial(:vote_box, locals: { entry: entry})
end

get '/entry/:id' do
  @entry = Entry.get!(params[:id]) rescue halt(404)
  erb :entry
end

# Dashboard

protect do
  get '/dash' do
    @entries = Entry.page(
      params[:page],
      per_page: 15,
      order: [((params[:order].nil? || params[:order].empty?) ? :vote_score : params[:order].to_sym).desc, :created_at.desc]
    )
    erb :dash, layout: false
  end

  post '/dash/remove_entry' do
    Entry.get!(params[:entry_id]).destroy rescue halt(404)
    redirect to "/dash?order=#{params[:order]}&page=#{params[:page]}"
  end
end

# Errors

not_found do
  '<h1>Not Found.</h1>'
end
