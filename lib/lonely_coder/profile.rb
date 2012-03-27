# encoding: UTF-8
class OKCupid
  
  def profile_for(username)
    Profile.by_username(username, @browser)
  end
  
  class Profile
    attr_accessor :username, :match, :friend, :enemy, :location,
                  :age, :sex, :orientation, :single, :small_avatar_url
    
    # extended profile details
    attr_accessor :last_online, :ethnicity, :height, :body_type, :diet, :smokes, 
                  :drinks, :drugs, :religion, :sign, :education, :job, :income, 
                  :offspring, :pets, :speaks, :profile_thumb_urls
    
                  
    # Scraping is never pretty.
    def self.from_search_result(html)
      
      username = html.search('span.username').text
      age, sex, orientation, single = html.search('p.aso').text.split('/')
      
      percents = html.search('div.percentages')
      match = percents.search('p.match .percentage').text.to_i
      friend = percents.search('p.friend .percentage').text.to_i
      enemy = percents.search('p.enemy .percentage').text.to_i
      
      location = html.search('p.location').text
      small_avatar_url = html.search('a.user_image img').attribute('src').value
      
      OKCupid::Profile.new({
        username: username,
        age: OKCupid.strip(age),
        sex: OKCupid.strip(sex),
        orientation: OKCupid.strip(orientation),
        single: OKCupid.strip(single),
        match: match,
        friend: friend,
        enemy: enemy,
        location: location,
        small_avatar_url: small_avatar_url
      })
    end
    
    def Profile.by_username(username, browser)
      html = browser.get("http://www.okcupid.com/profile/#{username}")
      
      percents = html.search('#percentages')
      match = percents.search('span.match').text.to_i
      friend = percents.search('span.friend').text.to_i
      enemy = percents.search('span.enemy').text.to_i
      
      basic = html.search('#aso_loc')
      age = basic.search('#ajax_age').text
      sex = basic.search('#ajax_gender').text
      orientation = basic.search('#ajax_orientation').text
      single = basic.search('#ajax_status').text
      location = basic.search('#ajax_location').text
      
      profile_thumb_urls = html.search('#profile_thumbs img').collect {|img| img.attribute('src').value}
      
      attributes = {
        username: username,
        match: match,
        friend: friend,
        enemy: enemy,
        age: age,
        sex: sex,
        orientation: orientation,
        location: location,
        single: single,
        profile_thumb_urls: profile_thumb_urls
      }
      
      details_div = html.search('#profile_details dl')
      
      details_div.each do |node|
        value = OKCupid.strip(node.search('dd').text)
        next if value == '—'
        
        attr_name = node.search('dt').text.downcase.gsub(' ','_')
        attributes[attr_name] = value
      end
      
      self.new(attributes)
    end
    
    def initialize(attributes)
      attributes.each do |attr,val|
        self.send("#{attr}=", val)
      end
    end
    
    def ==(other)
      self.username == other.username
    end
    
    def eql?(other)
      self.username == other.username
    end
    
    def hash
      if self.username
        self.username.hash
      else
        super
      end
    end
  end
end