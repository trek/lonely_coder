class OKCupid
  
  def authenticate(username, password)
    @authentication = Authentication.new(username, password, @browser)
  end
  
  class Authentication
    def initialize(username, password, browser)
      browser.get("https://www.okcupid.com/login") do |page|
        page.form_with(:action => '/login') do |form|
          form.username = username
          form.password = password
        end.submit
        @success = browser.page.uri.path == '/home'
      end
    end
    
    def success?
      @success
    end
  end
end