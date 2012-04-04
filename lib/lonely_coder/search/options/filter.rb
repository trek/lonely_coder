class OKCupid
 # Filter instances are used to build the query parameters for a search on OKCupid.
 # OKCupid has specific coded values for many search values, you should check the magic_constants file
 # for a list. Not all of them have been implemented yet.
 # 
 # Adding a Filter takes one of three forms:
 #    1) implementing a add_<filter_name>_option method on Search
 #       that pushes a new named Filter to the @filters array for unmamed query parts
 #    
 #    2) Subclassing Filter for filters that have atypical parameterization behavior.
 #       where you'll implement a add_<filter_name>_option method on Search
 #       and provide a custom class overriding `lookup` or `to_param` to create
 #       a correct url query part.
 # 
 #    3) Creating a new class to handle query parameters that are specifically named
 #       These are refered to as "Parameters" to contrast them with "Filters" which
 #       are parameterized in the "filterN=code,value" pattern (e.g. filter4=22,7).
 #       Parameters are not numbered and have specific names, e.g. "loc_id=1234567"
 #       You'll also implement a add_<filter_name>_option that adds an instance of this 
 #       class to the @parameters array (not the @filters array).
 # 
 #  See the included Filter and Parameter classes for ideas on how to structure these objects.
 # 
 #  OKCupid's query system is a bit obtuse and the details aren't published anywhere. 
 #  If you're implementing a new filter, you may need to spend some time figuring out
 #  what data they expect to receive and the kinds of results it will return.
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
  
  # All filters that follow the base Filter pattern are exposed here through a
  # add_<filter_name>_option method. Custom filters and parameters are defined
  # in their own files and include the appropriate add_<option_name>_option method.
  class Search
    def add_relationship_status_option(value)
      @filters << Filter.new('relationship_status', value)
    end
    
    def add_gentation_option(value)
      @filters << Filter.new('gentation', value)
    end
    
    def add_last_login_option(value)
      @filters << Filter.new('last_login', value)
    end
  end
end