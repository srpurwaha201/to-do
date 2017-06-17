require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default, 'sqlite:///'+Dir.pwd+'/project.db')

class User
	include DataMapper::Resource

	property :id, Serial
	property :email, String
	property :password, String
end

class Todo
	include DataMapper::Resource

	property :id,         Serial    
  	property :task,       String    
  	property :done,       Boolean 
  	property :important,  Boolean
  	property :urgent,	  Boolean
  	property :user_id,    Numeric
end

DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions

get '/' do
	if session[:user_id].nil?
		return redirect '/signin'
	else
		tasks = Todo.all(user_id: session[:user_id])
		erb: index locals: {user_id: session[:user_id], tasks: tasks}
end

get '/signin' do
	erb: signin
end

get '/signup'
	erb: signup
end

post '/signin' do
	email = params["email"]
	password = params["password"]
	user  = User.all(email: email).first

	if user.nil?
		return redirect '/signup'
	else
		if user.password == password
			session[:user_id] = user.id
			return redirect '/'
		else
			return redirect '/signin'
	end
end

post '/signup' do
	email = params["email"]
	password = params["password"]
	user = User.all(email: email).first
	if user
		return redirect '/signup'
	else
		user = User.new
		user.email = email
		user.password = password
		user.save
		session[:user_id] = user.id
		return redirect '/'
	end
end

get '/signout' do 
	session[:user_id] = nil
	return redirect '/'
end

post '/add' do
	new_Task = Todo.new
	new_Task.task = params["new_task"] 
	if params["important"] == "on"
		new_Task.important = true
	end
	if params["urgent"] == "on"
		new_Task.urgent = true
	end
	new_Task.user_id = session[:user_id]
	new_Task.save
	return redirect '/'
end

post '/toggle' do
	task_id = params["id"].to_i
	task = Todo.get (task_id)
	task.done = !task.done
	task.save
	return redirect '/'		
end
