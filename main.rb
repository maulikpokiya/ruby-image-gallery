require 'sinatra'
require 'sinatra/reloader' if development?
require './dbconnect'
#set :public_folder, 'assets'

configure do
	enable :sessions, :logging
	set :session_secret, 'itssecretandhardtoguess'
end

def setSession(uname)
	session[:user] = uname
end

def getSession
	@user = session[:user].inspect
	return @user
end

def loadPictures
	Dir.glob("public/pictures/*.{jpg}")
end

get '/' do 
	session.clear
	@pictures = loadPictures
	erb :register
end

post '/signUp' do 
	@uname = params['sign_up_username']
	@upwd = params['sign_up_password']
	u = PostgresDirect.new()
	u.connect

	begin
		if (u.prepareInsertUserStatement(@uname, @upwd)) then
			setSession(@uname)
			redirect '/home'
		else
			"Error in user insert"
		end
	rescue Exception => e
		puts e.message
		puts e.backtrace.inspect
	ensure
		u.disconnect
	end
end

post '/signIn' do 
	@uname = params['sign_in_username']
	@upwd = params['sign_in_password']
	s = PostgresDirect.new()
	s.connect

	begin
		@user = s.valiateUser(@uname, @upwd)
	rescue Exception => e
		puts e.message
		puts e.backtrace.inspect
	ensure
		s.disconnect
	end

	if (@user != nil) then
		setSession(@user)
		redirect '/home'
	else
		erb :do_login
	end
end

get '/home' do
	@pictures = []
	@user = getSession

	if (@user != nil) then
		p = PostgresDirect.new()
		p.connect

		begin
			p.queryImageTable {|row| @pictures << row }
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		ensure
			p.disconnect
		end

		erb :index
	else
		erb :do_login
	end
end

# Handle GET-request (Show the upload form)
get "/upload" do 
#	@user = getSession

#	if (@user == nil) then
#		erb :do_login
#	else
		erb :upload
#	end
end      
    
# Handle POST-request (Receive and save the uploaded file)
post "/upload" do 

#	if (@user != nil) then
		begin
			@new_name = rand(1000000)
			@path = 'public/pictures/' +@new_name.to_s+'.jpg'
		end while(File.exist?(@path))

		@pdesc = params['pic_desc']
		
		File.open(@path, "wb") do |f|
			#  File.open('public/pictures/' + params['myfile'][:filename], "wb") do |f|
			f.write(params['myfile'][:tempfile].read)
		end

		l = PostgresDirect.new()
		l.connect
		
		begin
			l.prepareInsertPictureStatement
			l.executeinsert(@path, @pdesc)
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		ensure
			l.disconnect
		end
		redirect '/home'
#	else
#		erb :do_login
#	end
#  return "The file was successfully uploaded!"
end

get "/public/picture/:image.to_s" do 
#	if (@user != nil) then
		redirect '/picture/:image'
#	else
#		erb :do_login
#	end
end

post '/search' do

#	if (@user != nil) then
		@pictures = []
		@user = getSession
		@keyword = params['imgSeach']

		r = PostgresDirect.new()
		r.connect

		begin
			r.searchImageTable(@keyword) {|row| @pictures << row }
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		ensure
			r.disconnect
		end

		erb :index
#	else
#		erb :do_login
#	end
end

get '/about' do 

#	if (@user != nil) then
		erb :about
#	else
#		erb :do_login
#	end
end