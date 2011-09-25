# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = 'facebook-login'
  gem.version = '0.3.0'

  gem.add_dependency 'oauth2', '>= 0.0.6'
  gem.add_dependency 'rack', '~> 1.2'
  gem.add_dependency 'addressable', '~> 2.1'
  gem.add_dependency 'hashie', '>= 0.2.0'
  # gem.add_development_dependency 'rspec', '~> 1.2.9'

  gem.summary = "REST library + Rack middleware for the Facebook Graph API"
  gem.description = "Easy integration with Facebook Graph for your application"

  gem.authors  = ['Mislav Marohnić']
  gem.email    = 'mislav.marohnic@gmail.com'
  gem.homepage = 'http://github.com/mislav/facebook'

  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*']

  if versioned = `git ls-files -z 2>/dev/null`.split("\0") and $?.success?
    gem.files &= versioned
  end
end
