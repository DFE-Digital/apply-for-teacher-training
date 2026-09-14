class ProviderInterface::FindCandidates::LocationTabNavigation < ApplicationComponent
  attr_reader :filter

  def initialize(filter)
    @filter = filter
  end

  def render?
    filter.filters['locations'].present?
  end

  def items
    filter.filters['locations'].map do |location|
      {
        current: false,
        name: location,
        url: provider_interface_candidate_pool_root_path(location:),
      }
    end
  end

  def call
    render TabNavigationComponent.new(items:)
  end
end
