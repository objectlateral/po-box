require_relative "../po_box"
require "rspec"
require "rack/test"
require "pry"

set :environment, :test

describe "PoBox" do
  include Rack::Test::Methods

  def app
    PoBox
  end

  def params
    {name: "Joe Blow", email: "joe@blow.com", message: "oh hai!"}
  end

  it "handles mail posted sans required params" do
    post "/mail"
    last_response.should be_unprocessable
  end

  it "handles mail posted with required params" do
    Pony.should_receive(:mail)
    post "/mail", params
    last_response.should be_ok
  end
end
