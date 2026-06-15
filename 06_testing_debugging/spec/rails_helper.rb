require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

# shoulda-matchers
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join('spec/fixtures')
  ]

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # ActiveSupport time helpers (freeze_time, travel_to)
  config.include ActiveSupport::Testing::TimeHelpers

  # Devise test helpers
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Bullet N+1 detection
  config.before(:each) do
    Bullet.start_request if Bullet.enable?
  end

  config.after(:each) do
    if Bullet.enable? && Bullet.notification?
      Bullet.perform_out_of_channel_notifications
    end
    Bullet.end_request if Bullet.enable?
  end
end
