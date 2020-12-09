module ProviderInterface
  class ApplicationDataExport
    def self.call(application_choices:)
      rows = []
      applications = Array.wrap(application_choices)

      applications.each do |application|
        first_degree = application.application_form.application_qualifications
                         .order(created_at: :asc)
                         .find_by(level: 'degree')

        rows << {
          'id' => application.id,
          'support_reference' => application.application_form.support_reference,
          'status' => application.status,
          'submitted_at' => application.application_form.submitted_at,
          'updated_at' => application.updated_at,
          'recruited_at' => application.recruited_at,
          'rejection_reason' => application.rejection_reason,
          'rejected_at' => application.rejected_at,
          'reject_by_default_at' => application.reject_by_default_at,
          'first_name' => application.application_form.first_name,
          'last_name' => application.application_form.last_name,
          'date_of_birth' => application.application_form.date_of_birth,
          'nationality' => application.application_form.first_nationality,
          'second_nationality' => application.application_form.second_nationality,
          'third_nationality' => application.application_form.third_nationality,
          'fourth_nationality' => application.application_form.fourth_nationality,
          'fifth_nationality' => application.application_form.fifth_nationality,
          'domicile' => application.application_form.country,
          'uk_residency_status' => application.application_form.uk_residency_status,
          'english_main_language' => application.application_form.english_main_language,
          'english_language_qualifications' => application.application_form.english_language_details,
          'email_address' => application.application_form.candidate.email_address,
          'phone_number' => application.application_form.phone_number,
          'address_line1' => application.application_form.address_line1,
          'address_line2' => application.application_form.address_line2,
          'address_line3' => application.application_form.address_line3,
          'address_line4' => application.application_form.address_line4,
          'postcode' => application.application_form.postcode,
          'country' => application.application_form.country,
          'recruitment_cycle_year' => application.application_form.recruitment_cycle_year,
          'provider_code' => application.provider.code,
          'accredited_body' => application.accredited_provider&.name,
          'course_code' => application.course.code,
          'site_code' => application.site.code,
          'study_mode' => application.course.study_mode,
          'start_date' => application.course.start_date,
          'FIRSTDEG' => ApplicationDataService.degrees_completed(application_form: application.application_form),
          'qualification_type' => first_degree&.qualification_type,
          'non_uk_qualification_type' => first_degree&.non_uk_qualification_type,
          'subject' => first_degree&.subject,
          'grade' => first_degree&.grade,
          'start_year' => first_degree&.start_year,
          'award_year' => first_degree&.award_year,
          'institution_details' => first_degree&.institution_name,
          'equivalency_details' => ApplicationDataService.composite_equivalency_details(qualification: first_degree),
          'awarding_body' => first_degree&.awarding_body,
          'gcse_qualifications_summary' => ApplicationDataService.gcse_qualifications_summary(application_form: application.application_form),
          'missing_gcses_explanation' => ApplicationDataService.missing_gcses_explanation(application_form: application.application_form),
          'disability_disclosure' => application.application_form.disability_disclosure,
        }
      end

      header_row ||= rows.first&.keys
      SafeCSV.generate(rows.map(&:values), header_row)
    end
  end
end
