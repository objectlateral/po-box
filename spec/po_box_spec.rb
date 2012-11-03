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

  context "Failure" do
    it "rejects mail posted sans required params" do
      post "/mail"
      last_response.should be_unprocessable
    end
  end

  context "Success" do
    before do
      @params = {
        name: "Joe Blow",
        email: "joe@blow.com",
        message: "oh hai!",
        token: "8675309"
      }
      @referer = "http://test.com/ohai"
      Pony.should_receive(:mail)
    end

    it "handles mail posted with required params" do
      post "/mail", @params
      last_response.should be_redirect
    end

    it "responds with 'ok' to ajax requests" do
      post "/mail", @params, {"HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"}
      last_response.should be_ok
    end

    it "redirects mail to referer when set" do
      post "/mail", @params, {"HTTP_REFERER" => @referer}
      last_response.should be_redirect
      last_response.headers["Location"].should == @referer
    end

    it "redirects to 'redirect' param when set" do
      url = "http://redirect.com/path"
      post "/mail", @params.merge(redirect: url), {"HTTP_REFERER" => @referer}
      last_response.should be_redirect
      last_response.headers["Location"].should == url
    end
  end
end
