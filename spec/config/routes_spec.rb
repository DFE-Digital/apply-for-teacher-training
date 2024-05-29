require 'rails_helper'

RSpec.describe 'routes.rb' do
  it 'does not use underscores' do
    paths = Rails.application.routes.routes.map { |r| r.path.spec.to_s if r.defaults[:controller] }.compact

    paths.each do |path|
      next if path.starts_with?('/rails')
      next if path == '/_system_test_entrypoint(.:format)'

      has_underscores = path.split('/').any? { |component| !component.start_with?(':') && component.match('_') }

      expect(has_underscores).to be(false), "#{path} should not have underscores"
    end
  end
end
