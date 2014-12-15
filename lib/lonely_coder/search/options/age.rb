class OKCupid
  class AgeFilter < Filter
    def lookup(value)
      "#{value[0]},#{value[1]}"
    end
  end

  class Search
    def add_age_option(value)
      @filters << AgeFilter.new('age', value)
    end
  end
end