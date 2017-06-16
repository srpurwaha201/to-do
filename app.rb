require 'sinatra'

class Todo
	attr_accessor :task,:done,:important,:urgent
	def initialize task
		@task = task
		@done = false
		@important = false
		@urgent = false
	end
end

tasks = []

get '/' do
	data = Hash.new
	data[:tasks] = tasks
	erb :index, locals: data
end

post '/add' do
	task_name = params["new_task"]
	new_Task = Todo.new task_name
	if params["important"] == "on"
		new_Task.important = true
	end
	if params["urgent"] == "on"
		new_Task.urgent = true
	end
	tasks << new_Task
	return redirect '/'
end

post '/toggle' do
	task_toggle = params["task_toggle"]
	tasks.each do |todo|
		if task_toggle == todo.task
			todo.done = !todo.done
		end
	end
	return redirect '/'			
end
