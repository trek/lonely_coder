require 'uri'
require 'set'

require 'lonely_coder/search/magic_constants'
require 'lonely_coder/search/search_pagination_parser'
require 'lonely_coder/search/options/filter'

# these are the included filters. See Filter class documentation for adding your own.
require 'lonely_coder/search/options/age'
require 'lonely_coder/search/options/ethnicity'
require 'lonely_coder/search/options/order_by'
require 'lonely_coder/search/options/location'
require 'lonely_coder/search/options/paginator'
require 'lonely_coder/search/options/radius'
require 'lonely_coder/search/options/require_photo'

class OKCupid
  # Creates a new Search with the passed options to act as query parameters.
  # A search will not trigger a query to OKCupid until `results` is called.
  #
  # @param [Hash] options a list of options for the search
  # @option options [Integer] :min_age (18) Minimum age to search for.
  # @option options [Integer] :max_age (99) Maximum age to search for.
  # @option options [String]  :gentation Gentation is OKCupid's portmanteau for 'gender and orientation'.
  #                           Acceptable values are:
  #                           "girls who like guys", "guys who like girls", "girls who like girls", 
  #                           "guys who like guys", "both who like bi guys", "both who like bi girls",
  #                           "straight girls only", "straight guys only", "gay girls only", 
  #                           "gay guys only", "bi girls only", "bi guys only", "everybody"
  #                           this option is required.
  # 
  # @option options [String]  :order_by ('match %') The sort order of the search results.
  #                           Acceptable values are 'match %','friend %', 'enemy %', 
  #                           'special blend', 'join', and 'last login'.
  #
  # @option options [Integer] :radius (25) The search radius, in miles.
  #                           Acceptable values are 25, 50, 100, 250, 500.
  #                           You must also specific a :location option.
  # @option options [Integer, String] :location ('near me'). A specific search location.
  #                                   Acceptable values are 'near me', 'anywhere', a "City, State" pair
  #                                   (e.g. 'Chicago, Illinois') or OKCupid location id which can be
  #                                   obtained with Search#location_id_for("City, State").
  #                                   If specifiying a location other than 'near me' or 'anywhere'
  #                                   you may also provide a :radius option
  # 
  # @option options [true, false] :require_photo (true). Search for profiles that have photos
  # @option options [String] :relationship_status ('single'). Acceptable values are 'single', 'not single', 'any'
  # @return [Search] A Search without results loaded. To trigger a query against OKCupid call `results`
  def search(options={})
    Search.new(options, @browser)
  end
  
  # The OKCupid search object. Stores filters and query options and a results set.  Correct usage is to obtain
  # and instance of this class by using OKCupid#search(options).
  # @see OKCupid#search
  class Search
    class FilterError < StandardError; end
    
    attr_reader :filters
    
    # @param [String] A string query for a city and state pair, e.g. 'Little Rock, Arkansas'
    # @return [Integer] The OKCupid location id for the query
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
      
      # :age appears as two options when creating a search
      # but is combined into one for paramterizing.
      options[:age] = combine_ages(options)
      
      # filters appear in the query string as filterN=code,value
      # e.g. filter4=11,75
      @filters = []
      
      # parameters appear in the query string as named query parameters
      # e.g. loc_id=1234567
      @parameters = []
      
      
      options.each do |name,value|
        self.send("add_#{name}_option", value)
      end
      
      # OKC needs an initial time key of 1 to represent "waaaay in the past"
      # futures searches will use the OKC server value returned from the first
      # results set.
      @timekey = 1
    end
    
    def check_for_required_options(options)
      raise(FilterError, 'gentation is a required option') unless options.has_key?(:gentation)
    end
    
    def combine_ages(options)
      age = [options.delete(:min_age), options.delete(:max_age)]
      options[:age] = age
    end
    
    #
    def defaults
      {
        :pagination => {
          :page => 1,
          :per_page => 10
        },
        :min_age => 18,
        :max_age => 99,
        :order_by => 'Match %',
        :last_login => 'last month',
        :location => 'Near me',
        :radius => 25,
        :require_photo => true,
        :relationship_status => 'single'
      }
    end
    
    def results
      return @results if @results
      
      # the first results request has to receive a full HTML page.
      # subseqent calls can make json requests
      page = @browser.get(url)
      
      # Stores the OKCupid server timestamp. Without this, pagination returns
      # inconsistent results.
      @timekey = page.search('script')[0].text.match(/CurrentGMT = new Date\(([\d]+)\*[\d]+\)/).captures[0]
      
      # OKCupid may return previously found profiles if there aren't enough
      # to fill a query or pagination, so we stop that with a set.
      @results = Set.new
      @results += page.search('.match_row').collect do |node|
        OKCupid::Profile.from_search_result(node)
      end
            
      @results
    end
    
    # no idea what the following parameters do. They don't appear to have 
    # an effect:
    # sort_type=0
    # fromWhoOnline=0
    # update_prefs=1
    # using_saved_search=0
    # mygender=m
    # 
    # no idea what the following parameters do, but without them, the search
    # behaves erratically
    # &custom_search=0
    # 
    # OKCupid timestamps searches for pagination. The first search gets a timestamp
    # of 1 (e.g. 1 second into the epoch) and future searches are stamped with
    # some server cache value. If that server value isn't submitted, the results
    # for pagniation don't quite match what you'd expect: you'll get duplicates, 
    # or lower numbers than expected.
    # &timekey=1
    def magic_params_not_truly_understood
      "timekey=#{@timekey}&custom_search=0"
    end
    
    
    # Loads the next page of possible results. Will return `true` if 
    # additional results were available or `false` if not
    # @return [true,false]
    def load_next_page
      @browser.pluggable_parser.html = SearchPaginationParser
      
      @pagination.next
      previous_length = @results.size
      
      page = @browser.get(ajax_url)
      
      @results += page.search('.match_row').collect do |node|
        OKCupid::Profile.from_search_result(node)
      end
      
      @browser.pluggable_parser.html = Mechanize::Page
      
      previous_length != @results.size
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
end