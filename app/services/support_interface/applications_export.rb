module SupportInterface
  class ApplicationsExport
    def applications
      relevant_applications.map do |application_form|
        output = {
          support_reference: application_form.support_reference,
          process_state: ProcessState.new(application_form).state,
          signed_up_at: application_form.candidate.created_at,
          first_signed_in_at: application_form.created_at,
          submitted_form_at: application_form.submitted_at,
          form_updated_at: application_form.updated_at,
          courses_last_updated_at: application_form.application_choices.max_by(&:updated_at)&.updated_at,
          qualifications_last_updated_at: application_form.application_qualifications.max_by(&:updated_at)&.updated_at,
          work_history_last_updated_at: application_form.application_work_experiences.max_by(&:updated_at)&.updated_at,
          references_last_updated_at: application_form.application_references.max_by(&:updated_at)&.updated_at,
        }

        audits = application_form.own_and_associated_audits

        %w[
          address_line1
          becoming_a_teacher
          country
          course_choices_completed
          date_of_birth
          degrees_completed
          disclose_disability
          english_main_language
          first_name
          first_nationality
          further_information
          interview_preferences
          last_name
          other_qualifications_completed
          phone_number
          postcode
          second_nationality
          subject_knowledge
          volunteering_completed
          volunteering_experience
          work_history_breaks
          work_history_completed
        ].each do |column|
          output[:"#{column}_last_updated_at"] = last_change_to_form(audits, column)
        end

        output
      end
    end

  private

    def last_change_to_form(audits, column)
      audits.find { |audit| audit.action == 'update' && audit.audited_changes.has_key?(column) }&.created_at
    end

    def relevant_applications
      ApplicationForm
        .includes(
          :candidate,
          :application_choices,
          :application_qualifications,
          :application_work_experiences,
          :application_references,
        )
        .where('candidates.hide_in_reporting' => false)
    end
  end
end
