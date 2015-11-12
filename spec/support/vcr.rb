require 'vcr'
require 'webmock/rspec'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
  c.hook_into :webmock
end
