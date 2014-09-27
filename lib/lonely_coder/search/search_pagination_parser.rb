require 'json'
class OKCupid
  # OKCupid's ajax pagination follows pjax pattern and returns json
  # with page fragments. We switch to this custom parser when
  # interaction with search.
  class SearchPaginationParser < Mechanize::Page
    def initialize(uri = nil, response = nil, body = nil, code =nil)
      body = JSON.parse(body)['html']
      super(uri, response, body, code)
    end
  end
end