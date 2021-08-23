module ProviderInterface
  class ApplicationDataExport
    CSV_HEADINGS = %w[
      application_choice_id candidate_id support_reference status submitted_at updated_at recruited_at
      rejection_reason rejected_at reject_by_default_at first_name last_name date_of_birth nationality
      domicile uk_residency_status english_main_language english_language_qualifications email phone_number
      address_line1 address_line2 address_line3 address_line4 postcode country recruitment_cycle_year
      provider_code accredited_provider_name accredited_provider_code course_code site_code study_mode
      start_date FIRSTDEG qualification_type non_uk_qualification_type subject grade start_year award_year
      institution_details equivalency_details awarding_body gcse_qualifications_summary missing_gcses_explanation
      disability_disclosure
    ].freeze

    def self.export_row(application_choice)
      return [] if application_choice.blank?

      application = ApplicationChoiceExportDecorator.new(application_choice)

      [
        application.id,
        application.application_form.candidate.public_id,
        application.application_form.support_reference,
        application.status,
        application.application_form.submitted_at,
        application.updated_at,
        application.recruited_at,
        application.rejection_reason,
        application.rejected_at,
        application.reject_by_default_at,
        application.application_form.first_name,
        application.application_form.last_name,
        application.application_form.date_of_birth,
        application.nationalities.join(' '),
        application.application_form.domicile,
        application.application_form.uk_residency_status,
        application.application_form.english_main_language,
        replace_smart_quotes(application.application_form.english_language_details),
        application.application_form.candidate.email_address,
        application.application_form.phone_number,
        application.application_form.address_line1,
        application.application_form.address_line2,
        application.application_form.address_line3,
        application.application_form.address_line4,
        application.application_form.postcode,
        application.application_form.country,
        application.application_form.recruitment_cycle_year,
        application.current_provider.code,
        application.current_accredited_provider&.name,
        application.current_accredited_provider&.code,
        application.current_course.code,
        application.current_site.code,
        application.current_course_option.study_mode,
        application.current_course.start_date,
        application.degrees_completed_flag,
        application.first_degree&.qualification_type,
        application.first_degree&.non_uk_qualification_type,
        application.first_degree&.subject,
        application.first_degree&.grade,
        application.first_degree&.start_year,
        application.first_degree&.award_year,
        application.first_degree&.institution_name,
        replace_smart_quotes(application.first_degree&.composite_equivalency_details),
        nil, # included for backwards compatibility. This column is always blank
        replace_smart_quotes(application.gcse_qualifications_summary),
        replace_smart_quotes(application.missing_gcses_explanation),
        application.application_form.disability_disclosure,
      ]
    end

    def self.replace_smart_quotes(text)
      text&.gsub(/(“|”)/, '"')&.gsub(/(‘|’)/, "'")
    end
  end
end
