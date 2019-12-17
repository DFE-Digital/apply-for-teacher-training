module CandidateInterface
  class ApplicationFormPresenter
    def initialize(application_form)
      @application_form = application_form
    end

    def updated_at
      "Last saved on #{@application_form.updated_at.strftime('%d %B %Y')} at #{@application_form.updated_at.strftime('%l:%M%P')}"
    end

    def sections_with_completion
      [
        # "Courses" section
        [:course_choices, course_choices_completed?],

        # "About you" section
        [:personal_details, personal_details_completed?],
        [:contact_details, contact_details_completed?],
        ([:training_with_a_disability, training_with_a_disability_completed?] if FeatureFlag.active?('training_with_a_disability')),
        [:work_experience, work_experience_completed?],
        [:volunteering, volunteering_completed?],

        # "Qualifications" section
        [:degrees, degrees_completed?],
        [:maths_gcse, maths_gcse_completed?],
        [:english_gcse, english_gcse_completed?],
        ([:science_gcse, science_gcse_completed?] if @application_form.science_gcse_needed?),
        # "Other qualifications" is intentionally omitted, since it's optional

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

    def ready_to_submit?
      sections_with_completion.map(&:second).all?
    end

    def application_choices_added?
      @application_form.application_choices.present?
    end

    def personal_details_completed?
      CandidateInterface::PersonalDetailsForm.build_from_application(@application_form).valid?
    end

    def contact_details_completed?
      contact_details = CandidateInterface::ContactDetailsForm.build_from_application(@application_form)

      contact_details.valid?(:base) && contact_details.valid?(:address)
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
        Rails.application.routes.url_helpers.candidate_interface_degrees_new_base_path
      end
    end

    def other_qualification_path
      if other_qualifications_completed? || other_qualifications_added?
        Rails.application.routes.url_helpers.candidate_interface_review_other_qualifications_path
      else
        Rails.application.routes.url_helpers.candidate_interface_new_other_qualification_path
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
      @application_form.maths_gcse.present?
    end

    def english_gcse_completed?
      @application_form.english_gcse.present?
    end

    def science_gcse_completed?
      @application_form.science_gcse.present?
    end

    def other_qualifications_completed?
      @application_form.other_qualifications_completed
    end

    def other_qualifications_added?
      @application_form.application_qualifications.other.any?
    end

    def becoming_a_teacher_completed?
      CandidateInterface::BecomingATeacherForm.build_from_application(@application_form).valid?
    end

    def subject_knowledge_completed?
      CandidateInterface::SubjectKnowledgeForm.build_from_application(@application_form).valid?
    end

    def interview_preferences_completed?
      CandidateInterface::InterviewPreferencesForm.build_from_application(@application_form).valid?
    end

    def training_with_a_disability_completed?
      @application_form.disclose_disability == false || \
        (@application_form.disclose_disability == true && \
          @application_form.disability_disclosure.present?)
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
      @application_form.application_references.count == ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end

  private

    def show_review_volunteering?
      volunteering_experience_is_set = [true, false].include?(@application_form.volunteering_experience)

      volunteering_completed? || volunteering_added? || volunteering_experience_is_set
    end
  end
end
