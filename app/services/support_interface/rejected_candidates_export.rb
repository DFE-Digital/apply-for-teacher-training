module SupportInterface
  class RejectedCandidatesExport
    def data_for_export
      application_forms = ApplicationForm.current_cycle.joins(:application_choices).includes(:application_choices, :candidate, :application_qualifications)

      rejected_applications = application_forms.find_each.select(&:ended_without_success?)

      rejected_candidates = rejected_applications.map(&:candidate).uniq

      output = rejected_candidates.map do |candidate|
        application_forms = candidate.application_forms.current_cycle.sort_by(&:id)
        application_form = application_forms.first
        apply_again_application = application_forms.second
        qualifications = application_form.application_qualifications
        a_levels = a_levels(qualifications).sort_by(&:subject)
        degrees = degrees(qualifications).sort_by(&:subject)

        {
          'First name' => application_form.first_name.split(' ').first,
          'Other names' => application_form.first_name.split(' ')[1..].join(' '),
          'Last name' => application_form.last_name,
          'Email address' => application_form.candidate.email_address,
          'Phone number' => application_form.phone_number,
          'Link to first application' => "https://www.apply-for-teacher-training.service.gov.uk/support/applications/#{application_form.id}",
          'First application submitted application on' => application_form.submitted_at&.to_date&.to_s,
          'First application choice status' => application_form.application_choices[0]&.status,
          'Second application choice status' => application_form.application_choices[1]&.status,
          'Third application choice status' => application_form.application_choices[2]&.status,
          'Applied again' => apply_again_application.present? ? 'Yes' : 'No',
          'Link to second application' => link_to_second_application_if_candidate_applied_again(apply_again_application),
          'Second application submitted on' => apply_again_application&.submitted_at&.to_date&.to_s,
          'Second application successful' => second_application_successful(apply_again_application),
          'Total applications this cycle' => candidate.application_forms.current_cycle.count,
          'GCSE maths grade' => maths_gcse_grade(qualifications),
          'GCSE science grade' => science_gcse_grade(qualifications),
          'GCSE English grade' => english_gcse_grade(qualifications),
          'A level 1 subject' => a_levels[0].try(:subject),
          'A level 1 grade' => a_levels[0].try(:grade),
          'A level 2 subject' => a_levels[1].try(:subject),
          'A level 2 grade' => a_levels[1].try(:grade),
          'A level 3 subject' => a_levels[2].try(:subject),
          'A level 3 grade' => a_levels[2].try(:grade),
          'A level 4 subject' => a_levels[3].try(:subject),
          'A level 4 grade' => a_levels[3].try(:grade),
          'A level 5 subject' => a_levels[4].try(:subject),
          'A level 5 grade' => a_levels[4].try(:grade),
          'Degree 1 type' => degrees[0].try(:qualification_type),
          'Degree 1 grade' => degrees[0].try(:grade),
          'Degree 2 type' => degrees[1].try(:qualification_type),
          'Degree 2 grade' => degrees[1].try(:grade),
          'Number of other qualifications provided' => other_qualification_count(qualifications),
        }
      end
      output
    end

  private

    def second_application_successful(application_form)
      if application_form&.ended_with_success?
        'Yes'
      else
        (application_form&.submitted_at.present? ? 'No' : nil)
      end
    end

    def link_to_second_application_if_candidate_applied_again(application_form)
      return nil if application_form.blank?

      "https://www.apply-for-teacher-training.service.gov.uk/support/applications/#{application_form.id}"
    end

    def maths_gcse_grade(qualifications)
      maths_gcse = qualifications.where(level: :gcse, subject: :maths).first
      maths_gcse&.grade
    end

    def english_gcse_grade(qualifications)
      gcse = qualifications.where(level: :gcse, subject: :english).first
      gcse&.structured_grades || gcse&.grade
    end

    def science_gcse_grade(qualifications)
      gcse = qualifications.where(level: :gcse, subject: :science).first
      gcse&.structured_grades || gcse&.grade
    end

    def a_levels(qualifications)
      qualifications.where(qualification_type: 'A level').or(qualifications.where(qualification_type: 'AS level')).reject(&:incomplete_other_qualification?).take(5)
    end

    def degrees(qualifications)
      qualifications.where(level: 'degree').reject(&:incomplete_degree_information?).take(2)
    end

    def other_qualification_count(qualifications)
      qualifications.where(level: 'other').count
    end
  end
end
