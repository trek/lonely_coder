require 'uri'

class OKCupid
  def search(options={})
    Search.new(options, @browser)
  end
  
  class Search
    class FilterError < StandardError; end
    
    attr_reader :filters
    
    def self.location_id_for(query)
      uri = URI("http://www.okcupid.com/locquery?func=query&query=#{URI.encode(query)}")
      JSON.parse(Net::HTTP.get(uri))['results'][0]['locid'].to_s
    end
    
    def initialize(options, browser = Mechanize.new)
      @browser = browser
      options = defaults.merge(options)
      parse(options)
    end
    
    def parse(options)
      combine_ages(options)
      check_for_required_options(options)
      remove_match_limit(options)
      
      @filters = []
      options.each do |name,value|
        
        if OKCupid.const_defined?("#{name.to_s.camelize}Filter")
          @filters << OKCupid.const_get("#{name.to_s.camelize}Filter").new(name, value)
        else
          @filters << Filter.new(name, value)
        end
      end
    end
    
    def remove_match_limit(options)
      @match_limit = options.delete(:match_limit)
    end
    
    def check_for_required_options(options)
      raise(FilterError, 'gentation is a required option') unless options.has_key?(:gentation)
    end
    
    def combine_ages(options)
      age = [options.delete(:min_age), options.delete(:max_age)]
      options[:age] = age
    end
    
    # Default values for search:
    # match_limit 80
    # min_age 18
    # max_age 99
    # order_by 'match %'
    # last_login 'last month'
    # location 'Near me'
    #    to search 'anywhere', use 'Near me' and omit a radius
    # radius 25
    # require_photo true
    # relationship_status 'single'
    def defaults
      {
        :match_limit => 80,
        :min_age => 18,
        :max_age => 99,
        :order_by => 'Match %',
        :last_login => 'last month',
        :location => 'Near me',
        :radius => 25, # acceptable values are 25, 50, 100, 250, 500, nil
        :require_photo => true,
        :relationship_status => 'single'
      }
    end
    
    def results
      return @results if @results
      
      page = @browser.get(url)
      @results = page.search('.match_row').collect do |node|
        OKCupid::Profile.from_search_result(node)
      end
    end
    
    def load_next_page
      @browser.pluggable_parser.html = SearchPaginationParser
      page = @browser.get("#{url}&low=11&count=10&ajax_load=1")
      @results += page.search('.match_row').collect do |node|
        OKCupid::Profile.from_search_result(node)
      end
      @browser.pluggable_parser.html = Mechanize::Page
      self
    end
    
    def url
      '/match?' + filters.compact.to_enum(:each_with_index).map {|filter,index| filter.to_param(index+1)}.join('&')
    end
  end
  
  class Filter
    class NoSuchFilter < StandardError; end
    class BadValue     < StandardError; end
    
    attr_reader :name, :value, :code
    
    def initialize(name, value)
      @code = MagicNumbers::Filters[name.to_s]
      raise(NoSuchFilter, name) unless @code
      
      @name = name.to_s
      @value = value
      @encoded_value = lookup(@value)
      unless @encoded_value
        raise(BadValue, "#{@value.inspect} is not a possible value for #{@name}. Try one of #{allowed_values.map(&:inspect).join(', ')}")
      end
    end
    
    def allowed_values
      MagicNumbers.const_get(@name.camelize).keys
    end
    
    def lookup(value)
      MagicNumbers.const_get(@name.camelize)[value.downcase]
    end
    
    def to_param(n)
      "filter#{n}=#{@code},#{@encoded_value}"
    end
  end
  
  class EthnicityFilter < Filter
    def lookup(values)
      # lookup the race values and sum them. I think OKC is doing some kind of base2 math on them
      values.collect {|v| MagicNumbers::Ethnicity[v.downcase]}.inject(0, :+)
    end
  end
  
  class LocationFilter < Filter
    def lookup(value)
      ''
    end
    
    def to_param(n)
      
      # to do: 'anywhere' needs to remove the radius filter
      if @value.is_a?(String)
        if @value.downcase == 'near me'
          "locid=0"
        else
          "lquery=#{URI.escape(@value)}"
        end
      else
        "locid=#{@value}"
      end
    end
  end
  
  class OrderByFilter < Filter
    def to_param(n)
      "matchOrderBy=#{@encoded_value}"
    end
  end
  
  # we fake this by paginating results ourselves.
  # class MatchLimitFilter < Filter
  #   def lookup(value)
  #     'MATCH'
  #   end
  #   
  #   def to_param(n)
  #     nil
  #   end
  # end
  
  class RequirePhotoFilter < Filter
    def lookup(value)
      value ? 1 : 0
    end
  end
    
  class RadiusFilter < Filter
    def lookup(value)
      value.nil? ? '' : value
    end
    
    def to_param(n)
      return nil if @encoded_value === ''
      super
    end
  end
  
  class AgeFilter < Filter
    def lookup(value)
      "#{value[0]},#{value[1]}"
    end
  end
end