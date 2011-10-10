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
    <title>Mini Sinatra Blog</title>
    <link rel="alternate" href="feed://subtlety.errtheblog.com/O_o/2d4.xml" type="application/atom+xml"/>
    <style type="text/css" media="screen">
      body { font: 75% "Helvetica", arial, Verdana, sans-serif; background: #FFB03B; }
      h1 { margin: 0; color: #8E2800; }
      h2 { margin-bottom: 0;}
      a { color: #468966; }
      #page { margin: 1em auto; width: 41.667em; border: 0.75em solid #B64926; background: white; padding: 2em; }
      .post { border-bottom: 0.4em double #FFB03B; padding-bottom: 1em;}
      .post .subtitle { padding-bottom: 1em; font-size: 83.333%; display: block;}
      #header, #footer { width: 47em; margin: 0 auto}
      #header h3 { font-size: 320%; margin: 0.5em 0 0 0; font-family: "Georgia";}
      #header h3 a { color: #FFF0A5; text-decoration: none; text-transform: uppercase; letter-spacing: 0.3em; text-shadow: #B64926 0.04em 0.04em;}
    </style>
  </head>
  <body>
    <div id="header"><h3><a href="/">Mini Blogin’</a></h3></div>
    <div id="page">
      <%= yield %>
    </div>
    <div id="footer">&copy; Erik <a href="http://metaatem.net/" alt="kastner">Kastner</a>. Source code on <a href="http://pastie.textmate.org/153325" title="#153325 by Erik Kastner (kastner) - Pastie">pastie</a></div>
  </body>
  </html>
  HTML
end

get '/' do
  res = "<h1>Posts</h1>"
  res += <<-HTML
  <div class="post">
    <p>Welcome. If you’d like to try adding a post. Point your editor at http://sin.metaatem.net/xml with any username.</p>
    <p>You can even upload files. However, you can only upload small files until Rack, or Sinatra or SOMEONE fixes TempFile uploads.</p>
  </div>
  HTML
  
  Post.find(:all, :limit => 20, :order => "created_at DESC").each do |p|
    # hAtom
    res << <<-HTML
    <div class="post hentry">
      <h2><a href="#{p.permalink}" class="entry-title" rel="bookmark">#{p.title}</a></h2>
      <span class="subtitle">Posted by 
        <span class="author vcard fn">#{p.author}</span> on 
        <abbr class="updated" title="#{p.updated_at.getgm.strftime("%Y-%m-%dT%H:%M:%SZ")}">#{p.updated_at.strftime("%D")}</abbr>
      </span>
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
