require 'rubygems'
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "sin.db")

begin
  ActiveRecord::Schema.define do
    create_table :posts do |t|
      t.string :title
      t.string :author
      t.text :description
      t.timestamps
    end
  end
rescue ActiveRecord::StatementInvalid
end

class Post < ActiveRecord::Base
  def permalink; "/posts/#{to_param}"; end
end

layout do
  <<-HTML
  <html>
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>Blog</title>
  </head>
  <body>
    <div id="header"><h3><a href="/">Blog</a></h3></div>
    <div id="page">
      <%= yield %>
    </div>
  </body>
  </html>
  HTML
end

get '/' do
  res = "<h1>Posts</h1>"
  
  Post.find(:all, :limit => 20, :order => "created_at DESC").each do |p|
    # hAtom
    res << <<-HTML
    <div class="post hentry">
      <h2><a href="#{p.permalink}" class="entry-title" rel="bookmark">#{p.title}</a></h2>
      <div class="content entry-content">
        #{p.description}
      </div>
    </div>
    
    HTML
  end
  erb res
end

get '/posts/:post*' do
    p = Post.find(params[:post])
    res = "<h1>#{p.title}</h1>"
    res << "#{p.updated_at.strftime("%D")}"
    res << "<p>#{p.description}</p>"
    erb res     
end