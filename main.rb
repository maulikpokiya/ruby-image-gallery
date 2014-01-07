require 'sinatra'
require 'sinatra/reloader' if development?
require './dbconnect'
#set :public_folder, 'assets'

def load_pictures
  Dir.glob("public/pictures/*.{jpg}")
end

get '/' do 
	@pictures = load_pictures
	erb :register
end

post '/signUp' do 
	@uname = params['sign_up_username']
	@upwd = params['sign_up_password']
	u = PostgresDirect.new()
	u.connect

	begin
		u.prepareInsertUserStatement(@uname, @upwd)
#		u.insertUser(@uname, @upwd)
		rescue Exception => e
			puts e.message
			puts e.backtrace.inspect
		ensure
			u.disconnect
	end

	redirect '/home'
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
		redirect '/home'
	else
		redirect '/'
	end
end

get '/home' do
	@pictures = []
	p = PostgresDirect.new()
	p.connect
	begin
	p.queryImageTable {|row| @pictures << row['name']}
	rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
	ensure
    p.disconnect
	end
  erb :index
end

# Handle GET-request (Show the upload form)
get "/upload" do
  erb :upload
end      
    
# Handle POST-request (Receive and save the uploaded file)
post "/upload" do 
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
#  return "The file was successfully uploaded!"
end

get "/public/picture/:image.to_s" do
redirect '/picture/:image'
end

post '/search' do
#  @pictures = load_pictures
	@pictures = []
	@keyword = params['imgSeach']
	r = PostgresDirect.new()
	r.connect
	begin
	r.searchImageTable(@keyword) {|row| @pictures << row['name']}
	rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
	ensure
    r.disconnect
	end
  erb :index
end