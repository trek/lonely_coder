# encoding: UTF-8
require 'bundler'
Bundler.require(:default, :test)
require 'lonely_coder'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end