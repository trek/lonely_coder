#encoding: UTF-8
require 'spec_helper'

describe "Profile" do
  it "checks for equality based on username" do
    OKCupid::Profile.new(:username => 'someguy', :age => 22).should == OKCupid::Profile.new(:username => 'someguy', :age => 35)
  end
end

describe "Profile from specific find" do
  before(:each) do
    VCR.use_cassette('search_by_username', :erb => {:username => ENV['OKC_USERNAME'], :password => ENV['OKC_PASSWORD']}) do
      @profile = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD']).profile_for('voliobi_te')
    end
  end
  
  it "has a username" do
    @profile.username.should == 'voliobi_te'
  end
  
  it "has an age" do
    @profile.age.should == '21'
  end
    
  it "has a match %" do
    @profile.match.should == 45
  end
  
  it "has a friend %" do
    @profile.friend.should == 56
  end
  
  it "has an enemy %" do
    @profile.enemy.should == 33
  end
  
  it "has a location" do
    @profile.location.should == 'Ann Arbor, Michigan'
  end
  
  it " doesn't has a small avatar url" do
    @profile.small_avatar_url.should == nil
  end
  
  it "has a collection of thumbnail urls" do
    @profile.profile_thumb_urls.should == ["http://akcdn.okccdn.com/media/img/user/d_160.png"]
  end
  
  it "has a sex" do
    @profile.sex.should == 'M'
  end
  
  it "has an orientation" do
    @profile.orientation.should == 'Gay'
  end
  
  it "has a signle status" do
    @profile.single.should == 'Single'
  end
  
  it "has a last_online" do
    @profile.last_online.should == "Today – 2:40am"
  end
  
  it "has a ethnicity" do
    @profile.ethnicity.should == 'White'
  end

  it "has a height" do
    @profile.height.should == '6′ 2″ (1.88m).'
  end

  it "has a body_type" do
    @profile.body_type.should == 'Thin'
  end

  it "has a diet" do
    @profile.diet.should == 'Mostly anything'
  end

  it "has a smokes" do
    @profile.smokes.should == 'No'
  end

  it "has a drinks" do
    @profile.drinks.should == 'Socially'
  end

  it "has a drugs" do
    @profile.drugs.should == 'Never'
  end

  it "has a religion" do
    @profile.religion.should == 'Agnosticism but not too serious about it'
  end

  it "has a sign" do
    @profile.sign.should == 'Gemini and it’s fun to think about'
  end

  it "has a education" do
    @profile.education.should == 'Working on college/university'
  end

  it "has a job" do
    @profile.job.should == 'Student'
  end

  it "has a income" do
    @profile.income.should == nil
  end

  it "has a offspring" do
    @profile.offspring.should == nil
  end

  it "has a pets" do
    @profile.pets.should == nil
  end

  it "has a speaks" do
    @profile.speaks.should == 'English (Fluently), Serbian (Fluently), Croatian (Fluently)'
  end
  
end

describe "Profile from search result" do
  before(:each) do
    VCR.use_cassette('search_by_filters', :erb => {:username => ENV['OKC_USERNAME'], :password => ENV['OKC_PASSWORD']}) do
      @profile = OKCupid.new(ENV['OKC_USERNAME'], ENV['OKC_PASSWORD']).search({
        gentation: 'girls who like guys'
      }).results.first
    end
  end
  
  it "has a username" do
    @profile.username.should == 'a2girl77'
  end
  
  it "has an age" do
    @profile.age.should == '34'
  end
    
  it "has a match %" do
    @profile.match.should == 92
  end
  
  it "has a friend %" do
    @profile.friend.should == 82
  end
  
  it "has an enemy %" do
    @profile.enemy.should == 0
  end
  
  it "has a location" do
    @profile.location.should == 'Ann Arbor, Michigan'
  end
  
  it "has a small avatar url" do
    @profile.small_avatar_url.should == 'http://ak0.okccdn.com/php/load_okc_image.php/images/82x82/82x82/126x67/497x439/2/5607892676107173868.jpeg'
  end
  
  it "has a sex" do
    @profile.sex.should == 'F'
  end
  
  it "has an orientation" do
    @profile.orientation.should == 'Straight'
  end
  
  it "has a signle status" do
    @profile.single.should == 'Single'
  end
end