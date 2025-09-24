module CandidateInterface
  class ApplicationFormPresenter
    include Rails.application.routes.url_helpers

    ErrorMessage = Struct.new(:message, :anchor)

    attr_reader :application_form

    delegate :apply_2?,
             :cache_key_with_version,
             :candidate_has_previously_applied?,
             :can_add_more_choices?,
             :can_add_course_choice?,
             :english_main_language,
             :application_limit_reached?,
             :first_name,
             :first_nationality,
             :previous_application_form,
             :phase,
             :personal_details_completed,
             :no_degree_and_degree_not_completed?,
             :previous_teacher_training_completed,
             :support_reference, to: :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def updated_at
      "Last saved on #{application_form.updated_at.to_fs(:govuk_date_and_time)}"
    end

    def sections_with_validations
      [
        # "About you" section
        [:personal_details, personal_details_section_errors.blank?],
        [:contact_details, contact_details_section_errors.blank?],
      ]
    end

    def sections_with_completion
      [
        # "About you" section
        [:personal_details, personal_details_completed?],
        [:contact_details, contact_details_completed?],
        [:training_with_a_disability, training_with_a_disability_completed?],
        [:work_experience, work_experience_completed?],
        [:volunteering, volunteering_completed?],
        [:safeguarding, safeguarding_completed?],
        [:equality_and_diversity, equality_and_diversity_completed?],
        [:previous_teacher_training, previous_teacher_training_completed?],

        # "Qualifications" section
        [:degrees, degrees_completed?],
        [:maths_gcse, maths_gcse_completed?],
        [:english_gcse, english_gcse_completed?],
        ([:science_gcse, science_gcse_completed?] if application_form.science_gcse_needed?),
        [:other_qualifications, other_qualifications_completed?],
        ([:efl, english_as_a_foreign_language_completed?] if display_efl_link?),

        # "Personal statement and interview" section
        [:becoming_a_teacher, becoming_a_teacher_completed?, becoming_a_teacher_review_pending?],
        [:interview_preferences, interview_preferences_completed?],

        # "References" section
        references_section_definition,
      ].compact
    end

    def references_section_definition
      [:references_selected, references_completed?]
    end

    def incomplete_sections
      section_structs = sections_with_completion
                          .reject(&:second)
                          .map do |sections_with_completion|
                            if sections_with_completion.first == :other_qualifications && application_form.international_applicant?
                              Struct.new(:name, :needs_review?).new(:other_qualifications_international, false)
                            else
                              Struct.new(:name, :needs_review?).new(sections_with_completion.first, sections_with_completion.third)
                            end
                          end

      section_structs.map do |section|
        message = section.needs_review? ? "review_application.#{section.name}.not_reviewed" : "review_application.#{section.name}.incomplete"
        Struct.new(:name, :message).new(section.name, message)
      end
    end

    ApplicationChoiceError = Struct.new(:message, :course_choice_id) do
      def anchor
        "#course-choice-#{course_choice_id}"
      end
    end

    def application_choice_errors
      [].tap do |error_list|
        application_form.application_choices.each do |choice|
          if choice.course_not_available?
            error_list << ApplicationChoiceError.new(
              choice.course_not_available_error, choice.id
            )
            next
          end

          if choice.course_application_status_closed?
            error_list << ApplicationChoiceError.new(
              choice.course_application_status_closed, choice.id
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
          if choice.site_invalid?
            error_list << ApplicationChoiceError.new(
              choice.site_invalid_error, choice.id
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

    def reference_section_errors
      # A defensive check, in case the candidate somehow ends up in this state
      [].tap do |errors|
        add_error_for_incomplete_reference(errors)
      end
    end

    def add_error_for_incomplete_reference(errors)
      if application_form.references_completed? && !application_form.complete_references_information?
        errors << ErrorMessage.new(
          I18n.t('application_form.references.review.incorrect_number'),
          '#references',
        )
      end
    end

    def ready_to_submit?
      sections_with_completion.map(&:second).all? &&
        sections_with_validations.map(&:second).all? &&
        application_choice_errors.empty? &&
        reference_section_errors.empty?
    end

    delegate :personal_details_completed?, to: :application_form

    def contact_details_completed?
      application_form.contact_details_completed
    end

    def contact_details_valid?
      contact_details_section_errors.blank?
    end

    def personal_details_section_errors
      PersonalDetailsForm.build_from_application(application_form).all_errors.map do |error|
        ErrorMessage.new(error.message, '#personal_details')
      end
    end

    def contact_details_section_errors
      ContactDetailsForm.build_from_application(application_form).all_errors.map do |error|
        ErrorMessage.new(error.message, '#contact_details')
      end
    end

    def work_experience_completed?
      application_form.work_history_completed
    end

    def work_experience_path(params = nil)
      if application_form.application_work_experiences.any? ||
         application_form.work_history_explanation.present? ||
         application_form.full_time_education?
        Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_review_path(params)
      else
        Rails.application.routes.url_helpers.candidate_interface_restructured_work_history_path(params)
      end
    end

    def degrees_path
      if no_degree_and_degree_not_completed?
        Rails.application.routes.url_helpers.candidate_interface_degree_university_degree_path
      else
        Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    def other_qualification_path
      if other_qualifications_completed? || other_qualifications_added? || application_form.no_other_qualifications
        Rails.application.routes.url_helpers.candidate_interface_review_other_qualifications_path
      else
        Rails.application.routes.url_helpers.candidate_interface_other_qualification_type_path
      end
    end

    def english_as_a_foreign_language_path
      if application_form.english_proficiency.present?
        Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_review_path
      else
        Rails.application.routes.url_helpers.candidate_interface_english_foreign_language_start_path
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
      application_form.degrees_completed
    end

    def maths_gcse_completed?
      application_form.maths_gcse_completed
    end

    def english_gcse_completed?
      application_form.english_gcse_completed
    end

    def science_gcse_completed?
      application_form.science_gcse_completed
    end

    def other_qualifications_completed?
      application_form.other_qualifications_completed && no_incomplete_qualifications?
    end

    def other_qualifications_added?
      application_form.application_qualifications.other.any?
    end

    def english_as_a_foreign_language_completed?
      application_form.efl_completed?
    end

    def becoming_a_teacher_completed?
      application_form.becoming_a_teacher_completed
    end

    def becoming_a_teacher_path
      if becoming_a_teacher_completed?
        Rails.application.routes.url_helpers.candidate_interface_becoming_a_teacher_show_path
      else
        Rails.application.routes.url_helpers.candidate_interface_new_becoming_a_teacher_path
      end
    end

    def becoming_a_teacher_review_pending?
      application_form.review_pending?(:becoming_a_teacher)
    end

    def interview_preferences_completed?
      application_form.interview_preferences_completed
    end

    def interview_preferences_valid?
      InterviewPreferencesForm.build_from_application(application_form).valid?
    end

    def training_with_a_disability_completed?
      application_form.training_with_a_disability_completed
    end

    def training_with_a_disability_valid?
      TrainingWithADisabilityForm.build_from_application(application_form).valid?
    end

    def course_choices_completed?
      application_form.course_choices_completed
    end

    def volunteering_completed?
      application_form.volunteering_completed
    end

    def volunteering_added?
      application_form.application_volunteering_experiences.any?
    end

    def references_completed?
      application_form.references_completed
    end

    def safeguarding_completed?
      application_form.safeguarding_issues_completed
    end

    def path_to_previous_teacher_training
      if application_form.published_previous_teacher_training&.reviewable?
        candidate_interface_previous_teacher_training_path(
          application_form.published_previous_teacher_training,
        )
      else
        start_candidate_interface_previous_teacher_trainings_path
      end
    end

    def equality_and_diversity_completed?
      application_form.equality_and_diversity_completed
    end

    def previous_teacher_training_completed?
      application_form.previous_teacher_training_completed
    end

    def safeguarding_valid?
      SafeguardingIssuesDeclarationForm.build_from_application(application_form).valid?
    end

    def no_incomplete_qualifications?
      application_form.application_qualifications.other.select(&:incomplete_other_qualification?).blank?
    end

    def display_efl_link?
      application_form.international_applicant?
    end

    def previous_application_choices_unsuccessful?
      application_form.previous_application_form.application_choices.rejected.any? ||
        application_form.previous_application_form.application_choices.offer_withdrawn.any?
    end

    def right_to_work_or_study_present?
      application_form.right_to_work_or_study.present?
    end

    def can_submit_more_applications?
      completed_application_form? && # The form is complete
        can_add_more_choices? && # They have not submitted the max number of choices
        can_add_course_choice? # The apply deadline for this form has not passed
    end

    def show_sections_not_carried_over_inset?
      # This is shown primary when an application is carried over,
      # when these sections may have been previously completed, but need to be revisited in the new year
      incomplete_sections.map(&:name).sort == %i[equality_and_diversity previous_teacher_training references_selected]
    end

  private

    def show_review_volunteering?
      no_volunteering_confirmed = application_form.volunteering_experience == false && application_form.application_volunteering_experiences.empty?

      volunteering_completed? || volunteering_added? || no_volunteering_confirmed
    end

    def completed_application_form?
      @completed_application_form ||= CandidateInterface::CompletedApplicationForm.new(application_form:).valid?
    end
  end
end
