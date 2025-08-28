module CandidateInterface
  class CarriedOverContentComponent < ViewComponent::Base
    delegate :after_find_opens?,
             :academic_year_range_name,
             :apply_opens_at,
             :find_opens_at,
             to: :@application_form, prefix: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def date_and_time_find_opens
      application_form_find_opens_at.to_fs(:govuk_date_time_time_first)
    end

    def date_and_time_apply_opens
      application_form_apply_opens_at.to_fs(:govuk_date_time_time_first)
    end
  end
end
