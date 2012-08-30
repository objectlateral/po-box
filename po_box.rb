require "rubygems"
require "bundler/setup"
require "sinatra"
require "rack/cors"
require "pony"

class PoBox < Sinatra::Base
  configure :production do
    Pony.options = {
      via: :smtp,
      via_options: {
        address: "smtp.sendgrid.net",
        port: "587",
        domain: "heroku.com",
        user_name: ENV["SENDGRID_USERNAME"],
        password: ENV["SENDGRID_PASSWORD"],
        authentication: :plain,
        enable_starttls_auto: true
      }
    }
  end

  configure :development, :test do
    Pony.options = {
      via: :smtp,
      via_options: {
        address: "localhost",
        port: "1025"
      }
    }
  end

  def nope(msg)
    error(422) { msg }
  end

  post "/mail" do
    [:name, :email, :message].each do |param|
      nope "#{param} required" unless params[param]
    end

    ip = env["HTTP_X_REAL_IP"] || env["REMOTE_ADDR"]
    body = "#{params[:name]}, #{params[:email]}, #{ip}\n\n#{params[:message]}"

    Pony.mail({
      to: "info@objectlateral.com",
      from: "po-box@objectlateral.com",
      subject: "Mail Delivery!",
      body: body
    })

    200
  end
end
