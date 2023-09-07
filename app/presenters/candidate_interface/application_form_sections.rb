module CandidateInterface
  class ApplicationFormSections
    def initialize(application_form:, application_choice:)
      @application_form = application_form
      @application_choice = application_choice
    end

    def all_completed?
      all_sections.map(&:second).all?
    end

    def completed?(section_name)
      sections_with_completion.find { |section| section[0] == section_name }&.second
    end

  private

    attr_reader :application_form, :application_choice

    def presenter
      @presenter ||= ApplicationFormPresenter.new(application_form)
    end

    def sections_with_completion
      presenter.sections_with_completion
    end

    def sections_with_validations
      presenter.sections_with_validations
    end

    def required_sections_with_completion
      sections_with_completion.reject do |section|
        %i[course_choices science_gcse].include?(section[0])
      end
    end

    def all_sections
      required_sections_with_completion + sections_with_validations
    end
  end
end
