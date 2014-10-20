Gem::Specification.new do |gem|
  gem.name        = 'voodoo_sms'
  gem.version     = '0.0.1'
  gem.date        = '2014-10-17'
  gem.summary     = 'VoodooSMS API'
  gem.description = 'Ruby wrapper for VoodooSMS API'
  gem.authors     = ['Tom Sabin']
  gem.email       = ['tom.sabin@unboxedconsulting.com']
  gem.files       = ['lib/voodoo_sms.rb']
  gem.homepage    = 'https://github.com/unboxed/voodoo-sms-ruby'
  gem.license     = 'MIT'
  gem.add_runtime_dependency     'httparty', '~> 0.13'
  gem.add_development_dependency 'rspec', '~> 3.1'
  gem.add_development_dependency 'vcr', '~> 2.9'
  gem.add_development_dependency 'webmock', '~> 1.19'
end
