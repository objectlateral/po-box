require "rubygems"
require "bundler/setup"
require "sinatra"
require "rack/cors"
require "pony"

class PoBox < Sinatra::Base
  use Rack::Cors do
    allow do
      origins "http://objectlateral.com", "http://objectlateral.github.com", /http:\/\/localhost*/
      resource "/mail", headers: :any, methods: [:post, :options]
    end
  end

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

    unless params[:token] and params[:token] == "8675309"
      nope "try again later!"
    end

    meta = [
      params[:name], params[:email], params[:stack], params[:ip]
    ].compact.join(", ")
    body = "#{meta}\n\n#{params[:message]}"

    Pony.mail({
      to: "info@objectlateral.com",
      from: "po-box@objectlateral.com",
      reply_to: params[:email],
      subject: "You've Got Mail!",
      body: body
    })

    if request.xhr?
      200
    else
      redirect params[:redirect] || request.referer
    end
  end
end
