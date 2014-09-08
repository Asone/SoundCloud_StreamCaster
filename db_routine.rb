#!/usr/bin/env ruby
# encoding: ASCII-8BIT

require 'soundcloud'
require 'yaml'
require 'json'
require 'time'
require 'terminal-notifier'

Conf = YAML.load_file(File.dirname(__FILE__)+'/config.yml')

client = Soundcloud.new(:client_id => Conf[:soundcloud][:client_id],
                        :client_secret => Conf[:soundcloud][:client_secret],
                        :username => Conf[:soundcloud][:username],
                        :password => Conf[:soundcloud][:password])

 File.open(File.dirname(__FILE__)+'/db.json', "r" ) do |f|
    @db = JSON.load( f )
  end

favs = client.get('/me/favorites?limit=400')

count_new = 0
# p @db
favs.each do |fav|

if( @db.find_index{|f| f['id'] == fav.id.to_i } == nil )
# p @db.find_index{|f| f['id'] == '84823317'}
#p fav.id.to_s
if(fav.stream_url.to_s != '')
f = { 'id' => fav.id,
	  'title' => fav.title.to_s,
     'poster' => fav.user.username, 
     'stream_url' => fav.stream_url.to_s,
     'cover' => fav.artwork_url,
     'discover_time' => Time.now.to_i,
     'downloaded' => false
     }
     
@db.push(f)
end
count_new = count_new + 1
else
p fav.id.to_s + 'already exists in db'
end


end

 File.open(File.dirname(__FILE__)+'/db.json', 'w') {|f| f.write @db.to_json } 
TerminalNotifier.notify(count_new.to_s + ' new sounds added to the soundcloud download list ') 