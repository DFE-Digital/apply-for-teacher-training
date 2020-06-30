module CandidateInterface
  class ApplicationFormPresenter
    def initialize(application_form)
      @application_form = application_form
    end

    def updated_at
      "Last saved on #{@application_form.updated_at.to_s(:govuk_date_and_time)}"
    end

    def sections_with_completion
      [
        # "Courses" section
        [:course_choices, course_choices_completed?],

        # "About you" section
        [:personal_details, personal_details_completed?],
        [:contact_details, contact_details_completed?],
        [:training_with_a_disability, training_with_a_disability_completed?],
        [:work_experience, work_experience_completed?],
        [:volunteering, volunteering_completed?],
        [:safeguarding, safeguarding_completed?],

        # "Qualifications" section
        [:degrees, degrees_completed?],
        [:maths_gcse, maths_gcse_completed?],
        [:english_gcse, english_gcse_completed?],
        ([:science_gcse, science_gcse_completed?] if @application_form.science_gcse_needed?),
        [:other_qualifications, no_incomplete_qualifications?],

        # "Personal statement and interview" section
        [:becoming_a_teacher, becoming_a_teacher_completed?],
        [:subject_knowledge, subject_knowledge_completed?],
        [:interview_preferences, interview_preferences_completed?],

        # "References" section
        [:references, all_referees_provided_by_candidate?],
      ].compact
    end

    def section_errors
      sections_with_completion
        .reject(&:second)
        .map(&:first)
    end

    ApplicationChoiceError = Struct.new(:message, :course_choice_id) do
      def anchor
        "#course-choice-#{course_choice_id}"
      end
    end

    def application_choice_errors
      [].tap do |error_list|
        @application_form.application_choices.each do |choice|
          if choice.course_not_available?
            error_list << ApplicationChoiceError.new(
              choice.course_not_available_error, choice.id
            )
            next
          end

          if choice.course_closed_on_apply?
            error_list << ApplicationChoiceError.new(
              choice.course_closed_on_apply_error, choice.id
            )
            next
          end

          if choice.course_full?
            error_list << ApplicationChoiceError.new(
              choice.course_full_error, choice.id
            )
            next
          end

          if choice.site_full?
            error_list << ApplicationChoiceError.new(
              choice.site_full_error, choice.id
            )
            next
          end

          next unless choice.study_mode_full?

          error_list << ApplicationChoiceError.new(
            choice.study_mode_full_error, choice.id
          )
        end
      end
    end

    def ready_to_submit?
      if FeatureFlag.active?('unavailable_course_option_warnings')
        sections_with_completion.map(&:second).all? &&
          application_choice_errors.empty?
      else
        sections_with_completion.map(&:second).all?
      end
    end

    def application_choices_added?
      @application_form.application_choices.present?
    end

    def personal_details_completed?
      @application_form.personal_details_completed?
    end

    def contact_details_completed?
      @application_form.contact_details_completed
    end

    def work_experience_completed?
      @application_form.work_history_completed
    end

    def work_experience_path
      if @application_form.application_work_experiences.any? || @application_form.work_history_explanation.present?
        Rails.application.routes.url_helpers.candidate_interface_work_history_show_path
      else
        Rails.application.routes.url_helpers.candidate_interface_work_history_length_path
      end
    end

    def degrees_path
      if degrees_completed? || degrees_added?
        Rails.application.routes.url_helpers.candidate_interface_degrees_review_path
      else
        Rails.application.routes.url_helpers.candidate_interface_new_degree_path
      end
    end

    def other_qualification_path
      if other_qualifications_completed? || other_qualifications_added?
        Rails.application.routes.url_helpers.candidate_interface_review_other_qualifications_path
      else
        Rails.application.routes.url_helpers.candidate_interface_new_other_qualification_type_path
      end
    end

    def volunteering_path
      if show_review_volunteering?
        Rails.application.routes.url_helpers.candidate_interface_review_volunteering_path
      else
        Rails.application.routes.url_helpers.candidate_interface_volunteering_experience_path
      end
    end

    def degrees_completed?
      @application_form.degrees_completed
    end

    def degrees_added?
      @application_form.application_qualifications.degrees.any?
    end

    def maths_gcse_completed?
      @application_form.maths_gcse_completed
    end

    def english_gcse_completed?
      @application_form.english_gcse_completed
    end

    def science_gcse_completed?
      @application_form.science_gcse_completed
    end

    def other_qualifications_completed?
      @application_form.other_qualifications_completed
    end

    def other_qualifications_added?
      @application_form.application_qualifications.other.any?
    end

    def becoming_a_teacher_completed?
      @application_form.becoming_a_teacher_completed
    end

    def subject_knowledge_completed?
      @application_form.subject_knowledge_completed
    end

    def interview_preferences_completed?
      @application_form.interview_preferences_completed
    end

    def training_with_a_disability_completed?
      @application_form.training_with_a_disability_completed
    end

    def course_choices_completed?
      @application_form.course_choices_completed
    end

    def volunteering_completed?
      @application_form.volunteering_completed
    end

    def volunteering_added?
      @application_form.application_volunteering_experiences.any?
    end

    def all_referees_provided_by_candidate?
      @application_form.references_completed
    end

    def safeguarding_completed?
      @application_form.safeguarding_issues_completed
    end

    def no_incomplete_qualifications?
      incomplete_qualifications = @application_form.application_qualifications.other.select(&:incomplete_other_qualification?)
      incomplete_qualifications.blank?
    end

  private

    def show_review_volunteering?
      volunteering_experience_is_set = [true, false].include?(@application_form.volunteering_experience)

      volunteering_completed? || volunteering_added? || volunteering_experience_is_set
    end

    def gcse_completed?(gcse)
      if gcse.present?
        if gcse.qualification_type != 'missing'
          gcse.grade.present? && gcse.award_year.present?
        else
          true
        end
      end
    end
  end
end
