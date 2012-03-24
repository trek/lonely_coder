require 'spec_helper'

describe "snagging a location id" do
  it "takes a query and returns an id" do
    VCR.use_cassette('find_location') do
      @loc_id = OKCupid::Search.location_id_for('Ann Arbor, MI')
    end
    
    @loc_id.should == '4305734'
  end
end