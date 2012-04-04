class OKCupid
  class OrderByParameter
    def initialize(value)
      @value = value
      @encoded_value = MagicNumbers::OrderBy[value.downcase]
    end
    
    def to_param
      "matchOrderBy=#{@encoded_value}"
    end
  end
  
  # Reopen Search to accept order_by filters
  class Search
    def add_order_by_option(value)
      @parameters << OrderByParameter.new(value)
    end
  end
end