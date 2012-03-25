require 'spec_helper'

describe "Search" do
  
  it "complains about missing required keys" do
    lambda { OKCupid::Search.new({}) }.should raise_error(OKCupid::Search::FilterError)
  end
  
  it "complains about malformed key values" do
    lambda { OKCupid::Search.new({
      :gentation => 'Cats who like laser beams',
    }) }.should raise_error(OKCupid::Filter::BadValue)
  end
  
  describe "generating the url" do
    it "combines all the filters into a params string" do
      OKCupid::Search.new({
        :min_age => 33,
        :max_age => 34,
        :order_by => 'Match %',
        :last_login => 'last decade',
        :gentation => 'Guys who like guys',
        :location => 'near me', # can be 'near me', 'anywhere', a location name (e.g. 'Ann Arbor, MI'), or a location id
        :radius => 25, # acceptable values are 25, 50, 100, 250, 500
        :require_photo => false,
        :relationship_status => 'any'
      }).url.should =='/match?filter1=5,315360000&filter2=3,25&filter3=1,0&filter4=35,0&filter5=0,20&filter6=2,33,34&low=1&count=10&matchOrderBy=MATCH&locid=0&timekey=1&custom_search=0'
    end
  end
end

describe "Results" do
  it "returns an array of OKCupid::Profile objects" do
    VCR.use_cassette('search_by_filters', :erb => {:username => ENV['OKC_USERNAME'], :password => ENV['OKC_PASSWORD']}) do
      @results = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD']).search({
        gentation: 'girls who like guys'
      }).results
    end
    
    @results.should be_kind_of(Array)
    @results.size.should == 10
    @results.all? {|p| p.kind_of?(OKCupid::Profile)}.should == true
  end
end

describe "Filters" do
  describe "lookup" do
    it "finds the encoded value" do
      OKCupid::Filter.new('relationship_status', 'single').lookup('single').should == 2
    end
  end
  
  describe "parameterization" do
    it "strings itself" do
      OKCupid::Filter.new('relationship_status', 'single').to_param(1).should == 'filter1=35,2'
    end
    
    it "custom filters: ethnicity are added together" do
      OKCupid::EthnicityFilter.new('ethnicity', ['white', 'black']).to_param(1).should == 'filter1=9,264'
    end
    
    it "custom filters: order_by" do
      OKCupid::OrderByParameter.new('Match %').to_param.should == 'matchOrderBy=MATCH'
    end
    
    it "custom filters: age" do
      OKCupid::AgeFilter.new('age', [18,22]).to_param(1).should == 'filter1=2,18,22'
    end
    
    it "custom filters: radius" do
      OKCupid::RadiusFilter.new('radius', 50).to_param(1).should == 'filter1=3,50'
    end
    
    it "custom filters: radius" do
      OKCupid::RadiusFilter.new('radius', nil).to_param(1).should == nil
    end
    
    describe "custom filters: require photo" do
      it "with true" do
        OKCupid::RequirePhotoFilter.new('require_photo', true).to_param(1).should == 'filter1=1,1'
      end
      
      it "with false" do
        OKCupid::RequirePhotoFilter.new('require_photo', false).to_param(1).should == 'filter1=1,0'
      end
    end
    
    describe 'custom filters: location' do
      it "can use the 'near me' value" do
        OKCupid::LocationParameter.new('Near me').to_param.should == 'locid=0'
      end
      
      it 'can use a location query' do
        OKCupid::LocationParameter.new('Cincinnati, Ohio').to_param.should == 'lquery=Cincinnati,%20Ohio'
      end
      
      it "can use a location_id" do
        OKCupid::LocationParameter.new(4335338).to_param.should == 'locid=4335338'
      end
    end
  end
end