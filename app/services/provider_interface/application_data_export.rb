module ProviderInterface
  class ApplicationDataExport
    def self.call(application_choices:)
      rows = []
      applications = Array.wrap(application_choices)

      applications.each do |application_choice|
        application = ApplicationChoiceExportDecorator.new(application_choice)

        rows << {
          'application_choice_id' => application.id,
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
          'nationality' => application.nationalities.join(' '),
          'domicile' => application.application_form.domicile,
          'uk_residency_status' => application.application_form.uk_residency_status,
          'english_main_language' => application.application_form.english_main_language,
          'english_language_qualifications' => replace_smart_quotes(application.application_form.english_language_details),
          'email' => application.application_form.candidate.email_address,
          'phone_number' => application.application_form.phone_number,
          'address_line1' => application.application_form.address_line1,
          'address_line2' => application.application_form.address_line2,
          'address_line3' => application.application_form.address_line3,
          'address_line4' => application.application_form.address_line4,
          'postcode' => application.application_form.postcode,
          'country' => application.application_form.country,
          'recruitment_cycle_year' => application.application_form.recruitment_cycle_year,
          'provider_code' => application.provider.code,
          'accredited_provider_name' => application.accredited_provider&.name,
          'accredited_provider_code' => application.accredited_provider&.code,
          'course_code' => application.course.code,
          'site_code' => application.site.code,
          'study_mode' => application.course.study_mode,
          'start_date' => application.course.start_date,
          'FIRSTDEG' => application.degrees_completed_flag,
          'qualification_type' => application.first_degree.qualification_type,
          'non_uk_qualification_type' => application.first_degree.non_uk_qualification_type,
          'subject' => application.first_degree.subject,
          'grade' => application.first_degree.grade,
          'start_year' => application.first_degree.start_year,
          'award_year' => application.first_degree.award_year,
          'institution_details' => application.first_degree.institution_name,
          'equivalency_details' => replace_smart_quotes(application.first_degree.composite_equivalency_details),
          'awarding_body' => nil,
          'gcse_qualifications_summary' => replace_smart_quotes(application.gcse_qualifications_summary),
          'missing_gcses_explanation' => replace_smart_quotes(application.missing_gcses_explanation),
          'disability_disclosure' => application.application_form.disability_disclosure,
        }
      end

      header_row ||= rows.first&.keys
      SafeCSV.generate(rows.map(&:values), header_row)
    end

    def self.replace_smart_quotes(text)
      text&.gsub(/(“|”)/, '"')&.gsub(/(‘|’)/, "'")
    end
  end
end
