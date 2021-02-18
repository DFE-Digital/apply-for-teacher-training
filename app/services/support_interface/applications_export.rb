module SupportInterface
  class ApplicationsExport
    def data_for_export(run_once_flag = false)
      applications_of_interest = ApplicationForm.includes(
        :candidate,
      ).preload(
        :application_choices,
        :associated_audits,
        :audits,
      ).where(
        'candidates.hide_in_reporting' => false,
      )

      results = []

      applications_of_interest.find_each(batch_size: 100) do |application_form|
        associated_audits = application_form.associated_audits.sort_by(&:created_at).reverse

        output = {
          candidate_id: application_form.candidate.id,
          support_reference: application_form.support_reference,
          recruitment_cycle_year: application_form.recruitment_cycle_year,
          phase: application_form.phase,
          process_state: ProcessState.new(application_form).state,
          signed_up_at: application_form.candidate.created_at,
          first_signed_in_at: application_form.created_at,
          submitted_form_at: application_form.submitted_at,
          form_updated_at: application_form.updated_at,
          courses_last_updated_at: associated_audits.find { |audit| audit.auditable_type == 'ApplicationChoice' }&.created_at,
          qualifications_last_updated_at: associated_audits.find { |audit| audit.auditable_type == 'ApplicationQualification' }&.created_at,
          work_history_last_updated_at: associated_audits.find { |audit| audit.auditable_type == 'ApplicationExperience' }&.created_at,
          references_last_updated_at: associated_audits.find { |audit| audit.auditable_type == 'ApplicationReference' }&.created_at,
        }

        this_application_audits = application_form
          .audits
          .select { |audit| audit.action == 'update' }
          .sort_by(&:created_at)
          .reverse

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
          # these are sorted by audit date, so the first time a given field appears
          # in the audit set is the last time it was touched
          value = this_application_audits.find { |audit| audit.audited_changes.key?(column) }&.created_at
          output[:"#{column}_last_updated_at"] = value
        end

        results << output
        break if run_once_flag
      end

      results
    end

    # alias_method :data_for_export, :applications
  end
end
