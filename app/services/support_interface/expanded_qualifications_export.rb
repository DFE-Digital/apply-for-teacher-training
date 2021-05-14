module SupportInterface
  class ExpandedQualificationsExport
    def data_for_export
      application_choices = ApplicationChoice
        .select(:id, :application_form_id, :status, :course_option_id)
        .includes(:course_option, :course, :provider, application_form: [:application_qualifications])
        .order(:application_form_id)

      application_choices.find_each(batch_size: 100).lazy.flat_map do |application_choice|
        application_form = application_choice.application_form
        course = application_choice.course
        qualifications = application_form.application_qualifications

        qualifications.map do |qualification|
          {
            application_form_id: application_form.id,
            qualification_id: qualification.id,
            candidate_id: application_form.candidate_id,
            support_reference: application_form.support_reference,
            phase: application_form.phase,
            recruitment_cycle_year: application_form.recruitment_cycle_year,

            choice_status: application_choice.status,
            course_code: course.code,
            provider_code: course.provider.code,

            level: qualification.level,
            qualification_type: qualification.qualification_type,
            other_uk_qualification_type: qualification.other_uk_qualification_type,
            award_year: qualification.award_year,
            subject: qualification.subject,
            predicted_grade: qualification.predicted_grade,
            grade: qualification.grade,
            constituent_grades: qualification.constituent_grades,
            international_degree: qualification.international,
            non_uk_qualification_type: qualification.non_uk_qualification_type,
            qualification_institution_name: qualification.institution_name,
            qualification_institution_country: qualification.institution_country,
            comparable_uk_degree: qualification.comparable_uk_degree,
            comparable_uk_qualification: qualification.comparable_uk_qualification,
          }
        end
      end
    end
  end
end
