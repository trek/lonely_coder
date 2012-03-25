# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name        = "lonely_coder"
  s.version     = '0.1.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Trek Glowacki"]
  s.email       = ["trek.glowacki@gmail.com"]
  s.homepage    = "http://github.com/trek/lonely_coder"
  s.summary     = %q{A gem for interacting with OKCupid as if it had an API}
  s.description = %q{A gem for interacting with OKCupid as if it had an API.}

  s.add_dependency 'mechanize', '= 2.0.1'
  s.add_dependency 'activesupport', '>= 3.2.1'

  s.post_install_message = %q{
    
    
    
    ,d88b.d88b,
    88888888888
    `Y8888888Y'
      `Y888Y'
        `Y'
    
        Good luck out there.
    
    
  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end