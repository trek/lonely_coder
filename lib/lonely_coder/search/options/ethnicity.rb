class OKCupid
  class EthnicityFilter < Filter
    def lookup(values)
      # lookup the race values and sum them. I think OKC is doing some kind of base2 math on them
      values.collect {|v| MagicNumbers::Ethnicity[v.downcase]}.inject(0, :+)
    end
  end

  class Search
    def add_ethnicity_option(values)
      @filters << EthnicityFilter.new('ethnicity', values)
    end
  end
end