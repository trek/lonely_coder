require 'spec_helper'

describe "EthnicityFilter" do
  it "adds ethnicity as an numbered filter to the query url" do
    @search = OKCupid::Search.new({
      :gentation => 'guys who like guys',
      :ethnicity => ['human']
    })
    @search.url.should match(/filter[\d]=9,512/)
  end
  
  it "supports mulitple ethnicity values" do
    @search = OKCupid::Search.new({
      :gentation => 'guys who like guys',
      :ethnicity => ['white', 'black']
    })
    # White + Black
    # 256 + 8
    @search.url.should match(/filter[\d]=9,264/)
  end
end