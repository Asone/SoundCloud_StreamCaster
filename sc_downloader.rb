#!/usr/bin/env ruby
# encoding: ASCII-8BIT
# dependencies
require 'soundcloud'
require 'json'
require 'taglib'
require 'yaml'
require 'fileutils'
require 'terminal-notifier'
require 'open-uri'

Conf = YAML.load_file(File.dirname(__FILE__)+'/config.yml')

# soundcloud client
client = Soundcloud.new(:client_id => Conf[:soundcloud][:client_id],
                        :client_secret => Conf[:soundcloud][:client_secret],
                        :username => Conf[:soundcloud][:username],
                        :password => Conf[:soundcloud][:password])


# get the files list

 File.open( File.dirname(__FILE__)+'/db.json', "r" ) do |f|
    @db = JSON.load( f )
  end

# exclude files already downloaded or processed

download_list = @db.clone.reject { | sc | !!sc['downloaded'] }



# sort by date so we download the oldest first
# TO FIX
download_list.sort { | a , b | b['discover_time'].to_i <=> a['discover_time'].to_i }

# check list length for loop 

if Conf[:filesmanager][:max_per_cycle].to_i>download_list.length
	max_dl = download_list.length-1	
else
	max_dl = Conf[:filesmanager][:max_per_cycle].to_i-1
end

for i in 0..max_dl

# Check if user folder already exists

	if Dir.exists?(ENV['HOME'] + Conf[:filesmanager][:dest]  + '/' + download_list[i]['poster'].to_s) != true
		
		# if not we create it
		
		FileUtils::mkdir_p ENV['HOME'] + Conf[:filesmanager][:dest]  + '/' + download_list[i]['poster'].to_s
	
	end
	
	# take out forbidden chars in filename
	
	download_list[i]['title'] = download_list[i]['title'].gsub(/\//,'-')
	
	begin
		puts 'Opening stream...'
		stream = client.get(download_list[i]['stream_url'].to_s)
	rescue Soundcloud::ResponseError => e
		if e.response.code == '404'
		puts 'Stream error 404.'
		puts 'skipping song'
			stream = false
		end
	else
		puts 'Stream is open !'
		puts 'Saving stream to file...'
		File.open( ENV['HOME'] + Conf[:filesmanager][:dest]  + '/' + download_list[i]['poster'].to_s + '/' + download_list[i]['title'] + '.mp3', 'w') {|f| f.write stream }
		puts 'file saved !'
		
		puts 'writing metadata'
		
		TagLib::MPEG::File.open( ENV['HOME'] + Conf[:filesmanager][:dest]  + '/' + download_list[i]['poster'].to_s + '/' + download_list[i]['title'] + ".mp3") do |mp3|
		
		 tag = mp3.id3v2_tag
		  # write basic attributes
		  tag.artist = download_list[i]['poster']
		  tag.title = download_list[i]['title']
		  # write cover if possible
		  if(!!download_list[i]['cover'])
			pic = URI.parse(download_list[i]['cover'].to_s).open { |f| f.read }
			apic = TagLib::ID3v2::AttachedPictureFrame.new
			apic.mime_type = "image/jpeg"
			apic.description = "Cover"
			apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
		    apic.picture =  pic
			tag.add_frame(apic)
		  end
		  mp3.save
		end
		
		p 'metadatas written'
	
		# update db object
		rows_to_update = @db.select{ |e| e['id'] == download_list[i]['id'] }
		rows_to_update.each do |f|
			f['downloaded'] = true
		end

		
	end
	
	
	
	
 

end

# save updated db to file

File.open(File.dirname(__FILE__)+'/db.json', 'w') {|f| f.write @db.to_json } 

  p 'DB file updated'

  # notify end of process 

  TerminalNotifier.notify(' soundcloud downloads done. ')


