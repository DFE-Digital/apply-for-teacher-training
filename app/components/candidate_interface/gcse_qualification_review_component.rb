module CandidateInterface
  class GcseQualificationReviewComponent < ActionView::Component::Base
    def initialize(application_qualification:, subject:, editable: true, heading_level: 2, missing_error: false)
      @application_qualification = application_qualification
      @subject = subject
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
    end

    def gcse_qualification_rows
      if application_qualification.missing_qualification?
        [missing_qualification_row]
      else
        [
          qualification_row,
          award_year_row,
          grade_row,
        ]
      end
    end

  private

    attr_reader :application_qualification, :subject

    def qualification_row
      {
        key: t('application_form.degree.qualification.label'),
        value: gcse_qualification_types[application_qualification.qualification_type.to_sym],
        action: "qualification for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        change_path: candidate_interface_gcse_details_edit_type_path(subject: subject),
      }
    end

    def award_year_row
      {
        key: 'Year awarded',
        value: application_qualification.award_year || t('gcse_summary.not_specified'),
        action: "year awarded for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        change_path: candidate_interface_gcse_details_edit_details_path(subject: subject),
      }
    end

    def grade_row
      {
        key: 'Grade',
        value: application_qualification.grade ? application_qualification.grade.upcase : t('gcse_summary.not_specified'),
        action: "grade for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        change_path: candidate_interface_gcse_details_edit_details_path(subject: subject),
      }
    end

    def missing_qualification_row
      {
        key: 'How I expect to gain this qualification',
        value: application_qualification.missing_explanation.presence || t('gcse_summary.not_specified'),
        action: 'how do you expect to gain this qualification',
        change_path: candidate_interface_gcse_details_edit_type_path(subject: subject),
      }
    end

    def gcse_qualification_types
      {
        gcse: 'GCSE',
        gce_o_level: 'GCE O Level',
        scottish_national_5: 'Scottish National 5',
        other_uk: application_qualification.other_uk_qualification_type,
      }
    end
  end
end
