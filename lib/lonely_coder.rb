#encoding: UTF-8

#   Hey there.
#           ,d88b.d88b,
#           88888888888
#           `Y8888888Y'
#             `Y888Y'
#               `Y'       - trek
#
require 'mechanize'

class OKCupid
  BaseUrl = 'http://www.okcupid.com'
  VERSION = '0.1.3'
  
  def initialize(username=nil, password=nil)
    @browser = Mechanize.new 
    @browser.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.79 Safari/535.11'
    authenticate(username, password)
  end
  
  WhiteSpace = "\302\240"
  def self.strip(str)
    str.gsub(WhiteSpace, ' ').strip
  end
  
  def love(n=20)
    ' ♥ ' * n
  end
end

require 'active_support/core_ext/string/inflections'

require 'lonely_coder/magic_constants'
require 'lonely_coder/profile'
require 'lonely_coder/search'
require 'lonely_coder/search_pagination_parser'
require 'lonely_coder/authentication'
require 'lonely_coder/mailbox'