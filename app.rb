require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/partial'
require 'escape_utils'
require 'sinatra/basic_auth'
require 'sinatra/content_for'

# Config

configure do
  set :block_repeated_votes, (ENV['BLOCK_REPEAT'] != "false") if production?
  set :block_repeated_votes, true unless production?
end

set :partial_template_engine, :erb
enable :partial_underscores

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
  
  property :vote_count,      Integer, :default => 0
  property :up_vote_count,   Integer, :default => 0
  property :down_vote_count, Integer, :default => 0
  property :vote_score,      Integer, :default => 0

  property :created_at,   DateTime
  property :update_at,    DateTime
  
  has n,   :votes,        :constraint => :destroy

  def vote(ip, up=true)
    return if already_voted?(ip)
    self.votes.create(:ip => ip, :up => up)
    self.vote_count      = self.votes.count
    self.up_vote_count   = self.votes.count(:up => true)
    self.down_vote_count = self.votes.count(:up => false)
    self.vote_score      = self.up_vote_count - self.down_vote_count
    self.save
  end

  def already_voted?(ip)
    (settings.block_repeated_votes? && self.votes.count(:ip => ip) != 0)
  end

  def voted_up?(ip)
    (settings.block_repeated_votes? && self.votes.all(:ip => ip).last.up)
  end

  def voted_down?(ip)
    not voted_up?(ip)
  end

  def self.sorted
    all(:order => [:vote_score.desc, :created_at.asc])
  end
end

class Vote
  include DataMapper::Resource

  property :id,           Serial
  property :ip,           String
  property :up,           Boolean, :default => true

  property :created_at,   DateTime
  property :update_at,    DateTime

  belongs_to :entry
end

DataMapper.finalize
DataMapper.auto_upgrade!

# Controllers

get '/' do
  @entries = Entry.all(:vote_score.gte => 0).sorted
  @burried_entries = Entry.all(:vote_score.lt => 0).sorted
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
  entry.vote(request.ip, params[:up] != 'false')
  if params[:vote_page]
    redirect to "/entry/#{entry.id}"
  else
    redirect to "/#suggestion-#{entry.id}"
  end
end

get '/entry/:id' do
  @entry = Entry.get!(params[:id])
  erb :entry
end

# Dashboard

protect do

  get '/dash' do
    @entries = Entry.page(params[:page], :per_page => 15, :order => [ ((params[:order].nil? || params[:order].empty?) ? :vote_score : params[:order].to_sym).desc, :created_at.desc ])
    erb :dash, :layout => false
  end

  post '/dash/remove_entry' do
    Entry.get!(params[:entry_id]).destroy
    redirect to "/dash?order=#{params[:order]}&page=#{params[:page]}"
  end

end
