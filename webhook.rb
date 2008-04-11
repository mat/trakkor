  require 'rubygems'
  require 'sinatra'
  require 'json'
  require 'yaml'

  get '/' do
    'Hello world! Visit /hook for the hook'
  end

  get '/hook' do
    changes = YAML::load(File.read('hook.txt'))
    "Received #{changes.length} items in total, last received: \n\n <pre> #{changes.last.to_yaml}</pre>"
  end


    def write(value)    
        f = File.new('hook.txt',  "w+")
        f.write([value].to_json)
        f.close()
    end

    def add(value)    
        f = File.new('hook.txt',  "r")
        yaml = f.read()
        list = YAML::load(yaml)
        puts "I GOT #{list.length} items here."

        f = File.new('hook.txt', "w+")
        list << value
        f.write(YAML::dump(list))
        f.close()
    end


  post '/hook' do
   raw_post_data = params[:payload]
   change = JSON.parse(params[:payload])

  add(change)
  "#{change.to_json} \n"
end


