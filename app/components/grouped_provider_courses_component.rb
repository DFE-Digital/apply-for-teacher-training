class GroupedProviderCoursesComponent < ActionView::Component::Base
  include ViewHelper

  validates :courses_by_provider_and_region, presence: true

  def initialize(courses_by_provider_and_region:)
    @courses_by_provider_and_region = courses_by_provider_and_region
  end

private

  attr_reader :courses_by_provider_and_region
end
