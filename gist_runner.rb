
require 'rubygems'
require 'sinatra/base'
require 'markaby'
require 'gist_loader'
require 'std_capture'
gem 'monkeybox', '=> 0.0.3'

class GistRunner < Sinatra::Base
	 include StdCapture
	m = Markaby::Builder.new
#	self.def_delegators :markaby, :h2,:form

	get '/gist' do
		gist_id = params[:gist_id] 
		main = params[:main] 
		#g = Gist.download(params[:gist_id])
		main = main ? "\"#{main}\"" : ""
		#puts main
		
		r = MonkeyBox.new.code(%{
			require 'gist_loader'
				g= nil
				e = nil
				r = nil
				g = Gist.download(#{params[:gist_id]})
			begin
				r = g.run(#{main})
			rescue Exception => err #this isn't the best way to do it. better to have Gist call monkeybox
				e = {:class => err.class.name, :message => err.message, :backtrace => err.backtrace}
			end
			[g,r,e]
		}).run
		
		#puts r.code
		gist,returned,error = *r.returned
	puts "++++++++++++++++++++++++++++"
	puts r.returned.inspect
	puts returned.inspect
	puts gist.inspect
	puts "++++++++++++++++++++++++++++"
		m.html {
	#		m.head { m.title "run #{g.description}:#{g.gist_id}" }
			m.head { m.title "run #{gist_id}" }
			m.body {
				h1 "run #{gist_id}:#{gist.description}" if gist
				#details on the gist, the owner, link to the page, created on etc.
				if r.error then
					h2 "MonkeyBox error: #{r.error[:class]}: #{r.error[:message]}"
#					h2 "#{r.error.class}"
					pre {
		#			puts error.inspect
						#self << r.error.inspect
						r.error[:backtrace].join("<br>")
					}
				end
				if error then
					h2 "#{error[:class]}: #{error[:message]}"
#					h2 "#{r.error.class}"
					pre {
		#			puts error.inspect
						#self << r.error.inspect
						error[:backtrace]
					}
				end
				h2 "Output:"
				pre.output r.output
				h2 "Returned:"
				pre.returned returned
			}
		}
	end

	get '/' do
		#puts self
		m.div {
			m.h2 "HELLO WORLD" 
			m.form(:action => '/gist', :method => :get	) {
					m.input :type=>:text,:name => :gist_id
					m.input :type=>:submit, :value=>"Send"

				#input for main file
					#b.button :value => :submit
				#submit.		
			}
		}
	end

#	def method_missing (method,*args,&block)
#		@mab.method(method).call(*args,&block)	
#	end
end

GistRunner.run! if __FILE__ == $0
