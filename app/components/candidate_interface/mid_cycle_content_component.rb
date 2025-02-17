module CandidateInterface
  class MidCycleContentComponent < ViewComponent::Base
    def initialize(application_form:)
      @application_form = application_form
    end

    attr_reader :application_form

    def application_form_presenter
      @application_form_presenter ||= CandidateInterface::ApplicationFormPresenter.new(application_form)
    end

    def max_number_of_applications
      ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS
    end

    def apply_reopens_date
      CycleTimetable.apply_reopens.to_fs(:month_and_year)
    end

    delegate :next_year, to: :CycleTimetable
  end
end
