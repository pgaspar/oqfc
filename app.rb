require 'sinatra'
require 'sinatra/reloader' if development?
require 'escape_utils'

# Config

configure do
  set :block_repeated_votes, (ENV['BLOCK_REPEAT'] != "false") if production?
  set :block_repeated_votes, true unless production?
end

# Database

require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db")

class Entry
  include DataMapper::Resource

  property :id,           Serial
  property :text,         String
  property :vote_count,   Integer, :default => 0

  property :created_at,   DateTime
  property :update_at,    DateTime
  
  has n,   :votes

  def vote(ip)
    return if already_voted?(ip)
    self.votes.create(:ip => ip)
    self.vote_count = self.votes.count
    self.save
  end

  def already_voted?(ip)
    (settings.block_repeated_votes? && self.votes.count(:ip => ip) != 0)
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
  @entries = Entry.all(:order => [:vote_count.desc, :created_at.desc])
  erb :index
end

post '/create_entry' do
  entry = Entry.create(:text => EscapeUtils.escape_html(params[:suggestion]))
  entry.vote(request.ip)
  redirect to "/#suggestion-#{entry.id}"
end

post '/vote' do
  entry = Entry.get(params[:entry_id])
  entry.vote(request.ip)
  redirect to "/#suggestion-#{entry.id}"
end
