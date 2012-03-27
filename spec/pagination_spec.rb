require 'spec_helper'

describe "pagination" do
  describe "success" do
    before(:each) do
      VCR.use_cassette('paginate_search_results_by_10', :erb => {:username => ENV['OKC_USERNAME'], :password => ENV['OKC_PASSWORD']}) do
        okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])

        @search = okc.search({
          gentation: 'girls who like guys',
          location: 4356796
        })
        @search.results
        @did_it_work = @search.load_next_page
      end
    end

    it "snags 10 more results" do
      @search.results.size.should == 20
      @search.results.all? {|p| p.kind_of?(OKCupid::Profile)}.should == true
    end
    
    it "returns true" do
      @did_it_work.should == true
    end
  end
  
  describe "failure" do
    before(:each) do
      VCR.use_cassette('paginate_search_results_by_10_with_failure', :erb => {:username => ENV['OKC_USERNAME'], :password => ENV['OKC_PASSWORD']}) do
        okc = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD'])

        @search = okc.search({
          gentation: 'guys who like guys',
          location: 4204350, # "Provo, Utah"
          min_age: 30,
          max_age: 30
        })
        @count = @search.results.size
        @did_it_work = @search.load_next_page
      end
    end

    it "doesn't snag any more results" do
      @search.results.size.should == @count
    end
    
    it "returns false" do
      @did_it_work.should == false
    end
  end
end