require 'json'

class OKCupid

  def authenticate(username, password)
    @authentication = Authentication.new(username, password, @browser)
  end

  class Authentication
    def initialize(username, password, browser)
      change_to_using_simpler_parser(browser)

      browser.post("https://www.okcupid.com/login", {
        username: username,
        password: password,
        okc_api: 1
      })

      body = JSON.parse(browser.page.body)

      # body['screenname'] will be `nil` for failed auth
      # and equal to the supplied username for success.
      # there may be other cases?
      @success = body['screenname'] != nil

      restore_default_parser(browser)
    end

    def success?
      @success
    end

    def change_to_using_simpler_parser(browser)
      browser.pluggable_parser.html = AuthenticationParser
    end

    def restore_default_parser(browser)
      browser.pluggable_parser.html = Mechanize::Page
    end
  end

  class AuthenticationParser < Mechanize::Page
    # We're only using page uri to determine successful login, so
    # there's not a lot of value in passing a body string to nokogiri
    def initialize(uri = nil, response = nil, body = nil, code =nil)
      super(uri, response, '', code)
    end
  end
end
