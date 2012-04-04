class OKCupid
  class LocationParameter
    def initialize(value)
      @value = value
    end
    
    def to_param
      if @value.is_a?(String)
        if @value.downcase == 'near me'
          "locid=0"
        else
          "locid=#{Search.location_id_for(@value)}&lquery=#{URI.escape(@value)}"
        end
      else
        "locid=#{@value}"
      end
    end
  end
  
  class Search
    def add_location_option(value)
      @parameters << LocationParameter.new(value)
    end
  end
end