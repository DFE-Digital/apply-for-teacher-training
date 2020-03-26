module ProviderInterface
  class ApplicationCardComponent < ActionView::Component::Base

    attr_accessor :accrediting_provider, :application_choice, :application_choice_path,
                  :candidate_name, :course_name_and_code, :course_provider_name, :index, :updated_at

    def initialize(application_choice:, index:)
      @accrediting_provider = application_choice.accrediting_provider
      @application_choice = application_choice
      @candidate_name = application_choice.application_form.full_name
      @course_name_and_code = application_choice.offered_course.name_and_code
      @course_provider_name = application_choice.offered_course.provider.name
      @index = index
      @updated_at = application_choice.updated_at.to_s(:govuk_date_short_month)
    end
  end
end
