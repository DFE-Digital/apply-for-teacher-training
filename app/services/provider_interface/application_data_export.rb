module ProviderInterface
  class ApplicationDataExport
    class << self
      def export_row(application_choice)
        return {} if application_choice.blank?

        application = ApplicationChoiceExportDecorator.new(application_choice)
        {
          'Application number' => application.id,
          'Recruitment cycle' => application.application_form.recruitment_cycle_timetable.cycle_range_name,
          'Status' => I18n.t("provider_application_states.#{application.status}", default: application.status),
          'Received date' => application.sent_to_provider_at,
          'Updated date' => application.updated_at,
          'First name' => application.application_form.first_name,
          'Last name' => application.application_form.last_name,
          'Date of birth' => application.application_form.date_of_birth,
          'Nationality' => application.nationalities.map { |nat| COUNTRIES_AND_TERRITORIES[nat] }.join(', '),
          'Nationality code' => application.nationalities.join(' '),
          'Disability support request' => application.application_form.disability_disclosure,
          'Email address' => application.application_form.candidate.email_address,
          'Phone number' => application.application_form.phone_number,
          'Contact address line 1' => application.application_form.address_line1,
          'Contact address line 2' => application.application_form.address_line2,
          'Contact address line 3' => application.application_form.address_line3,
          'Contact address line 4' => application.application_form.address_line4,
          'Contact postcode' => application.application_form.postcode,
          'Contact country' => COUNTRIES_AND_TERRITORIES[application_choice.application_form.country],
          'Contact country code' => application_choice.application_form.country,
          'Domicile' => application.domicile_country,
          'Domicile code' => application.application_form.domicile,
          'English is main language' => application.application_form.english_main_language.to_s.upcase,
          'English as a foreign language assessment details' => replace_smart_quotes(application.application_form.english_language_details),
          'Course' => application.current_course.name,
          'Course code' => application.current_course.code,
          'Training provider' => application.current_provider.name,
          'Training provider code' => application.current_provider.code,
          'Accredited body' => application.current_accredited_provider&.name,
          'Accredited body code' => application.current_accredited_provider&.code,
          'Location' => application.current_site.name,
          'Location code' => application.current_site.code,
          'Full time or part time' => application.current_course_option.study_mode.humanize,
          'Course start date' => application.current_course.start_date,
          'Has degree' => application.degrees_completed_flag == 1 ? 'TRUE' : 'FALSE',
          'Type of degree' => application.first_degree&.qualification_type,
          'Subject of degree' => application.first_degree&.subject,
          'Grade of degree' => application.first_degree&.grade,
          'Start year of degree' => application.first_degree&.start_year,
          'Award year of degree' => application.first_degree&.award_year,
          'Institution of degree' => application.first_degree&.institution_name,
          'Type of international degree' => application.first_degree&.non_uk_qualification_type,
          'Equivalency details for international degree' => replace_smart_quotes(application.formatted_equivalency_details),
          'GCSEs' => replace_smart_quotes(application.gcse_qualifications_summary),
          'Explanation for missing GCSEs' => replace_smart_quotes(application.missing_gcses_explanation),
          'Offered date' => application.offered_at,
          'Recruited date' => application.recruited_at,
          'Rejected date' => application.rejected_at,
          'Rejection reasons' => application.rejection_reasons,
          'Candidate ID' => application.application_form.candidate.public_id,
          'Support reference' => application.application_form.support_reference,
          'Offer accepted date' => application.accepted_at,
        }
      end

      def replace_smart_quotes(text)
        text&.gsub(/(“|”)/, '"')&.gsub(/(‘|’)/, "'")
      end
    end
  end
end
