module CandidateInterface
  class RejectionReasonsHistory
    class UnsupportedSectionError < StandardError; end
    HistoryItem = Struct.new(:provider_name, :section, :feedback)

    def self.all_previous_applications(application_form, section)
      new(application_form, section).all_previous_applications
    end

    def self.most_recent(application_form, section)
      new(application_form, section).most_recent
    end

    attr_reader :application_form, :section, :reasons_for_rejection_method

    def initialize(application_form, section)
      @application_form = application_form
      @section = section
      @reasons_for_rejection_method = map_section_to_method
    end

    def all_previous_applications
      previous_applications = collect_previous_applications(application_form)
      return [] if previous_applications.blank?

      previous_applications.flat_map do |application|
        extract_history(application.application_choices)
      end
    end

    def most_recent
      previous_application = application_form.previous_application_form
      return [] if previous_application.blank?

      extract_history(previous_application.application_choices)
    end

  private

    def collect_previous_applications(application_form)
      previous = application_form.previous_application_form
      [].tap do |collection|
        while previous.present?
          collection << previous
          previous = previous.previous_application_form
        end
      end
    end

    def extract_history(application_choices)
      application_choices.includes(:provider).filter_map do |choice|
        reasons_for_rejection = ReasonsForRejection.new choice.structured_rejection_reasons
        feedback = reasons_for_rejection.send reasons_for_rejection_method

        if feedback.present?
          HistoryItem.new(
            choice.provider.name,
            section,
            feedback,
          )
        end
      end
    end

    def map_section_to_method
      case section
      when :becoming_a_teacher
        :quality_of_application_personal_statement_what_to_improve
      else
        raise UnsupportedSectionError
      end
    end
  end
end
