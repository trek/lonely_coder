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
      check_for_required_options(options)
      
      options[:age] = combine_ages(options)
      
      
      @filters = []
      @parameters = []
      
      options.each do |name,value|
        self.send("add_#{name}_option", value)
        # if OKCupid.const_defined?("#{name.to_s.camelize}Filter")
        #   @filters << OKCupid.const_get("#{name.to_s.camelize}Filter").new(name, value)
        # else
        #   @filters << Filter.new(name, value)
        # end
      end
    end
    
    def add_order_by_option(value)
      @parameters << OrderByParameter.new(value)
    end
    
    def add_last_login_option(value)
      @filters << Filter.new('last_login', value)
    end
    
    def add_location_option(value)
      @parameters << LocationParameter.new(value)
    end
    
    def add_radius_option(value)
      @filters << RadiusFilter.new('radius', value)
    end
    
    def add_require_photo_option(value)
      @filters << RequirePhotoFilter.new('require_photo', value)
    end
    
    def add_relationship_status_option(value)
      @filters << Filter.new('relationship_status', value)
    end
    
    def add_gentation_option(value)
      @filters << Filter.new('gentation', value)
    end
    
    def add_age_option(value)
      @filters << AgeFilter.new('age', value)
    end
    
    def add_pagination_option(value)
      @parameters << @pagination = Paginator.new(value)
    end
    
    def add_match_limit_option(value)
      # TODO.
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
        :pagination => {
          :page => 1,
          :per_page => 10
        },
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
      
      @browser.pluggable_parser.html = SearchPaginationParser
      page = @browser.get(ajax_url)
      
      @results = page.search('.match_row').collect do |node|
        OKCupid::Profile.from_search_result(node)
      end
      
      @browser.pluggable_parser.html = Mechanize::Page
      
      @results
    end
    
    # no idea what the following parameters do. They don't appear to have 
    # an effect:
    # sort_type=0
    # fromWhoOnline=0
    # update_prefs=1
    # using_saved_search=0
    # mygender=m
    # no idea what the following parameters do, but without them, the search
    # behaves erratically
    # &timekey=1
    # &custom_search=0
    def magic_params_not_truly_understood
      "timekey=1&custom_search=0"
    end
    
    def load_next_page
      @browser.pluggable_parser.html = SearchPaginationParser
      
      page = @browser.get("#{ajax_url}&#{@pagination.next.to_param}")
      
      @results += page.search('.match_row').collect do |node|
        OKCupid::Profile.from_search_result(node)
      end
      
      @browser.pluggable_parser.html = Mechanize::Page
      
      self
    end
    
    def url
      "/match?#{filters_as_query}&#{parameters_as_query}&#{magic_params_not_truly_understood}"
    end
    
    def ajax_url
      "#{url}&ajax_load=1"
    end
    
    def parameters_as_query
      @parameters.collect {|param| param.to_param }.join('&')
    end
    
    def filters_as_query
      filters.compact.to_enum(:each_with_index).map {|filter,index| filter.to_param(index+1)}.join('&')
    end
  end
  
  # used to create the pagination part of a search url:
  # low=1&count=10&ajax_load=1
  # where low is the start value
  # count is the number of items per page
  class Paginator
    attr_reader :page, :per_page
    
    def initialize(options)
      @per_page = options[:per_page]
      @page = options[:page]
    end
    
    def low
      @low = ((@page - 1) * @per_page) + 1
    end
    
    def next
      @page +=1
      self
    end
    
    def to_param
      "low=#{low}&count=#{@per_page}"
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
  
  class LocationParameter
    def initialize(value)
      @value = value
    end
    
    def to_param
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

  class OrderByParameter
    def initialize(value)
      @value = value
      @encoded_value = MagicNumbers::OrderBy[value.downcase]
    end
    
    def to_param
      "matchOrderBy=#{@encoded_value}"
    end
  end

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