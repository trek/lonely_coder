class OKCupid
  class RequirePhotoFilter < Filter
    def lookup(value)
      value ? 1 : 0
    end
  end

  class Search
    def add_require_photo_option(value)
      @filters << RequirePhotoFilter.new('require_photo', value)
    end
  end
end