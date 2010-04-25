# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = 'facebook'
  gem.version = '0.1.0'
  gem.date    = Date.today.to_s

  gem.add_dependency 'oauth2', '>= 0.0.6'
  gem.add_dependency 'yajl-ruby', '~> 0.7.5'
  gem.add_dependency 'rack', '~> 1.1.0'
  # gem.add_development_dependency 'rspec', '~> 1.2.9'

  gem.summary = "REST library + Rack middleware for the Facebook Graph API"
  gem.description = "Easy integration with Facebook Graph for your application"

  gem.authors  = ['Mislav Marohnić']
  gem.email    = 'mislav.marohnic@gmail.com'
  gem.homepage = 'http://github.com/mislav/facebook'

  gem.rubyforge_project = nil
  gem.has_rdoc = true
  gem.rdoc_options = ['--main', 'README.rdoc', '--charset=UTF-8']
  gem.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'CHANGELOG.rdoc']

  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*']
  gem.files &= versioned if versioned = `git ls-files -z 2>/dev/null`.split("\0") and $?.success?
end
