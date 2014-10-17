require 'bundler/setup'
Bundler.setup
require 'voodoo_sms'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |c|
  c.around(:each, vcr: :success) do |spec|
    VCR.use_cassette("success/#{vcr_cassette}") { spec.run }
  end

  c.around(:each, vcr: :errors) do |spec|
    VCR.use_cassette("errors/#{vcr_cassette}") { spec.run }
  end
end
