module CandidateInterface
  class RejectionReasonsHistory
    class UnsupportedSectionError < StandardError; end
    HistoryItem = Struct.new(:provider_name, :section, :feedback, :feedback_type)

    FEEDBACK_REJECTION_REASONS_TYPES = %w[
      reasons_for_rejection
      rejection_reasons
      vendor_api_rejection_reasons
    ].freeze

    def self.all_previous_applications(application_form, section)
      new(application_form, section).all_previous_applications
    end

    def self.previous_application(application_form, section)
      new(application_form, section).previous_application
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

    def previous_application
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
        next if choice.structured_rejection_reasons.blank?

        feedback = feedback_for_choice(choice)

        if feedback.present?
          HistoryItem.new(
            choice.provider.name,
            section,
            feedback,
            choice.rejection_reasons_type,
          )
        end
      end
    end

    def feedback_for_choice(choice)
      return unless FEEDBACK_REJECTION_REASONS_TYPES.include?(choice.rejection_reasons_type)

      send(:"feedback_for_#{choice.rejection_reasons_type}", choice)
    end

    def feedback_for_reasons_for_rejection(choice)
      reasons_for_rejection = ReasonsForRejection.new(choice.structured_rejection_reasons)
      reasons_for_rejection.send(reasons_for_rejection_method)
    end

    def feedback_for_rejection_reasons(choice)
      send(:"feedback_for_#{section}", ::RejectionReasons.new(choice.structured_rejection_reasons))
    end

    def feedback_for_vendor_api_rejection_reasons(choice)
      if section == :becoming_a_teacher
        reasons = ::RejectionReasons.new(choice.structured_rejection_reasons)
        [reasons.find('personal_statement')].compact
      end
    end

    def feedback_for_becoming_a_teacher(rejection_reasons)
      %w[quality_of_writing personal_statement_other]
        .map { |id| rejection_reasons.find(id) }
        .compact
    end

    def feedback_for_subject_knowledge(rejection_reasons)
      [rejection_reasons.find('subject_knowledge')].compact
    end

    def map_section_to_method
      case section
      when :becoming_a_teacher
        :quality_of_application_personal_statement_what_to_improve
      when :subject_knowledge
        :quality_of_application_subject_knowledge_what_to_improve
      else
        raise UnsupportedSectionError
      end
    end
  end
end
