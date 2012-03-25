require 'spec_helper'

describe "Paginator" do
  before(:each) do
    @page = OKCupid::Paginator.new({
      page: 1,
      per_page: 5
    })
  end
  
  it "paramiterizes itself" do
    @page.to_param.should == "low=1&count=5"
  end
  
  it "stores the current page" do
    @page.page.should == 1
  end
  
  it "stores the per page value" do
    @page.per_page.should == 5
  end
  
  it "low is lowest item number for the current page" do
    @page.low.should == 1
  end
  
  describe "incrementing" do
    before(:each) do
      @page.next
    end
    
    it "incremens the current page" do
      @page.page.should == 2
    end

    it "low is lowest item number for the current page" do
      @page.low.should == 6
    end
    
    it "updates the params itself" do
      @page.to_param.should == "low=6&count=5"
    end
  end
end