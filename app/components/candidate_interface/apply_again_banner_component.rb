module CandidateInterface
  class ApplyAgainBannerComponent < ViewComponent::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def show_deadline_copy?
      EndOfCycleTimetable.show_apply_2_deadline_banner? && FeatureFlag.active?(:deadline_notices)
    end
  end
end
