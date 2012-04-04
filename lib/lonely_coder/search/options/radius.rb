class OKCupid
  class RadiusFilter < Filter
    def lookup(value)
      value.nil? ? '' : value
    end
    
    def to_param(n)
      return nil if @encoded_value === ''
      super
    end
  end
  
  class Search
    def add_radius_option(value)
      @filters << RadiusFilter.new('radius', value)
    end
  end
end