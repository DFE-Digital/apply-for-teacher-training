module ProviderInterface
  class ApplicationDataExport
    class << self
      def export_row(application_choice)
        return {} if application_choice.blank?

        application = ApplicationChoiceExportDecorator.new(application_choice)

        {
          'Application number' => application.id,
          'Recruitment cycle' => RecruitmentCycle.cycle_name(application.application_form.recruitment_cycle_year),
          'Status' => I18n.t("provider_application_states.#{application.status}", default: application.status),
          'Received date' => application.application_form.submitted_at,
          'Date for automatic rejection' => application.reject_by_default_at,
          'Updated date' => application.updated_at,
          'First name' => application.application_form.first_name,
          'Last name' => application.application_form.last_name,
          'Date of birth' => application.application_form.date_of_birth,
          'Nationality code' => application.nationalities.join(' '),
          'Nationality' => application.nationalities.map { |nat| COUNTRIES_AND_TERRITORIES[nat] }.join(', '),
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
          'Equivalency details for international degree' => replace_smart_quotes(application.first_degree&.composite_equivalency_details),
          'Institution of international degree' => nil, # included for backwards compatibility. This column is always blank
          'GCSEs' => replace_smart_quotes(application.gcse_qualifications_summary),
          'Explanation for missing GCSEs' => replace_smart_quotes(application.missing_gcses_explanation),
          'Offered at' => application.offered_at,
          'Recruited date' => application.recruited_at,
          'Rejected date' => application.rejected_at,
          'Was automatically rejected' => application.rejected_by_default ? 'TRUE' : 'FALSE',
          'Rejection reasons' => rejection_reasons(application_choice),
          'Candidate ID' => application.application_form.candidate.public_id,
          'Support reference' => application.application_form.support_reference,
        }
      end

      def replace_smart_quotes(text)
        text&.gsub(/(“|”)/, '"')&.gsub(/(‘|’)/, "'")
      end

      def rejection_reasons(application_choice)
        reasons = RejectedApplicationChoicePresenter.new(application_choice).rejection_reasons
        return if reasons.nil?

        reasons = reasons.transform_values(&:compact)
        reasons&.map { |k, v| %(#{k.upcase}\n\n#{Array(v).join("\n\n")}) }&.join("\n\n")
      end
    end
  end
end
