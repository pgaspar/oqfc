require 'sinatra'
require 'sinatra/reloader' if development?
require 'escape_utils'
require 'sinatra/basic_auth'
require 'sinatra/content_for'

# Config

configure do
  set :block_repeated_votes, (ENV['BLOCK_REPEAT'] != "false") if production?
  set :block_repeated_votes, true unless production?
end

authorize do |username, password|
  username == "admin" && password == "cfqoOQFC!!"
end

# Database

require 'data_mapper'
require 'dm-pager'
require 'dm-validations'
require 'dm-constraints'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db")

class Entry
  include DataMapper::Resource

  property :id,           Serial
  property :text,         Text, :length => 1..300
  property :vote_count,   Integer, :default => 0

  property :created_at,   DateTime
  property :update_at,    DateTime
  
  has n,   :votes,        :constraint => :destroy

  def vote(ip)
    return if already_voted?(ip)
    self.votes.create(:ip => ip)
    self.vote_count = self.votes.count
    self.save
  end

  def already_voted?(ip)
    (settings.block_repeated_votes? && self.votes.count(:ip => ip) != 0)
  end

  def self.sorted
    all(:order => [:vote_count.desc, :created_at.desc])
  end
end

class Vote
  include DataMapper::Resource

  property :id,           Serial
  property :ip,           String

  property :created_at,   DateTime
  property :update_at,    DateTime

  belongs_to :entry
end

DataMapper.finalize
DataMapper.auto_upgrade!

# Controllers

get '/' do
  @entries = Entry.sorted
  erb :index
end

post '/create_entry' do
  entry = Entry.create(:text => EscapeUtils.escape_html(params[:suggestion]))
  redirect back unless entry.saved?

  entry.vote(request.ip)
  redirect to "/#suggestion-#{entry.id}"
end

post '/vote' do
  entry = Entry.get!(params[:entry_id])
  entry.vote(request.ip)
  redirect to "/#suggestion-#{entry.id}"
end

# Dashboard

protect do

  get '/dash' do
    @entries = Entry.page(params[:page], :per_page => 15, :order => [ ((params[:order].nil? || params[:order].empty?) ? :vote_count : params[:order].to_sym).desc, :created_at.desc ])
    erb :dash, :layout => false
  end

  post '/dash/remove_entry' do
    Entry.get!(params[:entry_id]).destroy
    redirect to "/dash?order=#{params[:order]}&page=#{params[:page]}"
  end

end
