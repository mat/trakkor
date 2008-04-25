  require 'rubygems'
  require 'sinatra'
  require 'json'
  require 'yaml'
  require 'net/smtp'

MAIL_SERVER = 'mail.gmx.net'
LOGIN  = File.read('/home/mat/.mail_login').reverse.strip
PASSWORD = File.read('/home/mat/.mail_pw').reverse.strip


FROM_EMAIL = 'matthias-luedtke@gmx.de'
TO_EMAIL = 'email@matthias-luedtke.de'

def message(from, to, body, subject='')
msg = <<END_OF_MESSAGE
From: #{from}
To: #{to}
Subject: #{subject}

#{body}
END_OF_MESSAGE

end


def send_mail(msg)
Net::SMTP.start(MAIL_SERVER, 25, 'localhost.localdomain', LOGIN, PASSWORD, :login) do |smtp|
  smtp.send_message msg, FROM_EMAIL, TO_EMAIL
  end
  puts 'k, send mail'
  end

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

  send_mail(message(FROM_EMAIL, TO_EMAIL, change['change']['new']['text'], "Mendono: #{change['change']['tracker']['name']}"))
  add(change)
  "#{change.to_json} \n"
end


