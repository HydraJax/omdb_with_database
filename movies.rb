require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'

# A setup step to get rspec tests running.
configure do
  root = File.expand_path(File.dirname(__FILE__))
  set :views, File.join(root,'views')
end

get '/' do
  erb :search_form
end

get '/movies' do
  # /movies comes from the form action
  c = PGconn.new(:host => "localhost", :dbname => 'moviesdb')
  # host maps to a string so it needs to be in quotes
  @movies = c.exec_params("select * from search where name=$1;",[params["title"]])
  
  # title comes from the html form
  erb :display_search
 end
  
get '/movie/:id' do
  # view for details of one movie
  # does extra search for the imdb movies_info
  movies_info[title]
  # $1 allows us to use this as a placeholder to pass something into the sql
  c.close
  erb :index
end

post '/movies/new' do
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2)",
                  [params["title"], params["year"]])

  # for ruby variables we use the $ placeholder insert into an array
  c.close
  redirect '/'
end

def dbname
  "moviesdb" 
  # table name search 
  # change this to your db
end

def create_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec %q{
  CREATE TABLE movies (
    id SERIAL PRIMARY KEY,
    title varchar(255),
    year varchar(255),
    plot text,
    genre varchar(255)
  );
  }
  connection.close
end

def drop_movies_table
  connection = PGconn.new(:host => "localhost", :dbname => dbname)
  connection.exec "DROP TABLE movies;"
  connection.close
end

def seed_movies_table
  movies = [["Glitter", "2001"],
              ["Titanic", "1997"],
              ["Sharknado", "2013"],
              ["Jaws", "1975"]
             ]
 
  c = PGconn.new(:host => "localhost", :dbname => dbname)
  movies.each do |p|
    c.exec_params("INSERT INTO movies (title, year) VALUES ($1, $2);", p)
  end
  c.close
end

