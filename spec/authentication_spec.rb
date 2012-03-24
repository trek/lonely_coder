require 'spec_helper'

describe 'Authentication' do
  it "returns true if successful" do
    VCR.use_cassette('successful_authentication', :erb => {username: ENV['OKC_USERNAME'], password: ENV['OKC_PASSWORD']}) do
      auth = OKCupid::Authentication.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'], Mechanize.new)
      auth.success?.should == true
    end
  end
  
  it "returns false if not successful" do
    VCR.use_cassette('failed_authentication') do
      auth = OKCupid::Authentication.new('thisisnotauser', 'thisisnotapassword', Mechanize.new)
      auth.success?.should == false
    end
  end
end