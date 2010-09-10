require 'rubygems'
require 'httparty'
require 'quick_attr'

class Gist 
	extend QuickAttr

	quick_attr :gist_id, :description, :data
	quick_array :file_names #so the order is preserved,
	quick_attr :files, :loaded

	def initialize
		files Hash.new
		loaded Hash.new
	end

	def self.header(gist_id)
		gist = HTTParty.get "http://gist.github.com/api/v1/xml/#{gist_id}"

		g = Gist.new.gist_id(gist_id)
		g.data gist.parsed_response["gists"].first
		g.description g.data['description']
		gist.parsed_response["gists"].first["files"].each{|e|
			g.file_names << e['file']
		}
		#puts g.inspect
		g
	end
	def require (file)
		if files[file] then
			eval files[file]
		elsif files["#{file}.rb"] then
			eval files["#{file}.rb"]
		else
  			super	
  		end
	end
	def self.gist_file(gist_id,filename)
			HTTParty.get("http://gist.github.com/raw/#{gist_id}/#{filename}").body
	end
	def self.download  (gist_id)
		gist = header gist_id
		gist.file_names.each{|e|
			gist.files[e] = gist_file(gist.gist_id,e)
		}
		gist
	end 
	
	def run (file=nil)
		file = file_names.first unless file
#		if file then
	#		puts "load #{file}"
			r = eval files[file],binding,file,1 #	unless loaded[file]
			loaded[file] = true
			return r
#		else
#			file_names.first {|e|
#				return eval e if e and files[e]	
#			}
#		end
	end
end

if __FILE__ == $0 then
  gist_id = ARGV[0]
  g = Gist.download(gist_id)
  puts g.inspect
  puts g.run(ARGV[1]).inspect
end
