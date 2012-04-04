class OKCupid
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
  
  class Search
    def add_pagination_option(value)
      @parameters << @pagination = Paginator.new(value)
    end
  end
end