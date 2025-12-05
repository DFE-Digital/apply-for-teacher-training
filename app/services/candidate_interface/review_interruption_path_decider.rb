module CandidateInterface
  class ReviewInterruptionPathDecider
    include Rails.application.routes.url_helpers

    INTERRUPTION_STEPS = %i[
      initial_step
      short_personal_statement
      grade_incompatible
      undergraduate_course_with_degree
      enic
      references_with_personal_email_addresses
    ].freeze

    def self.decide_path(application_choice, current_step: :initial_step)
      new(application_choice).call(current_step)
    end

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def call(step)
      step = increment_step(step)
      return candidate_interface_course_choices_course_review_and_submit_path(application_choice.id) if step.nil?

      if show_interruption_page_for_step?(step)
        interruption_page_path(step)
      else
        call(step)
      end
    end

    def increment_step(step)
      current_index = INTERRUPTION_STEPS.index(step)
      INTERRUPTION_STEPS[current_index + 1]
    end

  private

    attr_reader :application_choice

    def show_interruption_page_for_step?(step)
      case step

      when :short_personal_statement
        short_personal_statement?
      when :grade_incompatible
        grade_incompatible?
      when :undergraduate_course_with_degree
        application_choice.undergraduate_course_and_application_form_with_degree?
      when :enic
        missing_enic_reference?
      when :references_with_personal_email_addresses
        references_with_personal_email_addresses?
      end
    end

    def interruption_page_path(step)
      case step

      when :short_personal_statement
        candidate_interface_course_choices_course_review_interruption_path(application_choice.id)
      when :grade_incompatible
        candidate_interface_course_choices_course_review_degree_grade_interruption_path(application_choice.id)
      when :undergraduate_course_with_degree
        candidate_interface_course_choices_course_review_undergraduate_interruption_path(application_choice.id)
      when :enic
        candidate_interface_course_choices_course_review_enic_interruption_path(application_choice.id)
      when :references_with_personal_email_addresses
        candidate_interface_course_choices_course_review_references_interruption_path(application_choice.id)
      end
    end

    def application_form
      @application_form ||= application_choice.application_form
    end

    def references_with_personal_email_addresses?
      application_form.unsubmitted? &&
        application_form.application_references.pluck(:referee_type, :email_address).any? do |referee_type, email_address|
          referee_type != 'character' && email_address.present? && EmailChecker.new(email_address).personal?
        end
    end

    def short_personal_statement?
      application_form.becoming_a_teacher.scan(/\S+/).size < ApplicationForm::RECOMMENDED_PERSONAL_STATEMENT_WORD_COUNT
    end

    def grade_incompatible?
      DegreeGradeEvaluator.new(@application_choice).degree_grade_below_required_grade?
    end

    def missing_enic_reference?
      application_form.qualifications_enic_reasons_waiting_or_maybe? ||
        application_form.any_qualification_enic_reason_not_needed?
    end
  end
end
