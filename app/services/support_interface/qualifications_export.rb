module SupportInterface
  class QualificationsExport
    def data_for_export
      application_choices = ApplicationChoice
        .select(:id, :application_form_id, :rejection_reason, :structured_rejection_reasons, :status, :course_option_id)
        .includes(:course_option, :course, :provider, application_form: [:application_qualifications])

      application_choices.find_each(batch_size: 100).lazy.map do |application_choice|
        application_form = application_choice.application_form
        course = application_choice.course
        qualifications = application_form.application_qualifications.all
        a_levels = a_levels(qualifications).sort_by(&:subject)
        degrees = degrees(qualifications).sort_by(&:subject)

        output = {
          'Candidate id' => application_form.candidate_id,
          'Support ref' => application_form.support_reference,
          'Phase' => application_form.phase,
          'Cycle' => application_form.recruitment_cycle_year,

          'Outcome (offer, rejected etc.)' => application_choice.status,
          'Reason for Rejection' => application_choice.structured_rejection_reasons || application_choice.rejection_reason,
          'Course Code' => course.code,
          'Provider Code' => course.provider.code,

          'GCSE maths grade' => maths_gcse_grade(qualifications),

          'GCSE science single grade' => science_single_gcse_grade(qualifications),
          'GCSE science double grade' => science_double_gcse_grade(qualifications),
          'GCSE science triple grade' => science_triple_gcse_grade(qualifications),

          'GCSE English unstructured grade' => english_unstructured_gcse_grade(qualifications),
          'GCSE English single grade' => english_structured_gcse_grades(qualifications, 'english_single_award'),
          'GCSE English double grade' => english_structured_gcse_grades(qualifications, 'english_double_award'),
          'GCSE English language grade' => english_structured_gcse_grades(qualifications, 'english_language'),
          'GCSE English literature grade' => english_structured_gcse_grades(qualifications, 'english_literature'),
          'GCSE English studies single grade' => english_structured_gcse_grades(qualifications, 'english_studies_single_award'),
          'GCSE English studies double grade' => english_structured_gcse_grades(qualifications, 'english_studies_double_award'),
          'GCSE English other grade' => english_other_gcse_grade(qualifications),

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

        output
      end
    end

  private

    def maths_gcse_grade(qualifications)
      maths_gcse = qualifications.find { |qualification| qualification.gcse? && qualification.subject == 'maths' }
      maths_gcse.try(:grade)
    end

    def science_single_gcse_grade(qualifications)
      unstructured_grade = unstructured_gcse_science_grade_from(qualifications)
      return unstructured_grade if unstructured_grade.present? && SINGLE_GCSE_GRADES.include?(unstructured_grade)

      find_science_gcse(
        qualifications: qualifications,
        award: ApplicationQualification::SCIENCE_SINGLE_AWARD,
      ).try(:grade)
    end

    def science_double_gcse_grade(qualifications)
      unstructured_grade = unstructured_gcse_science_grade_from(qualifications)
      return unstructured_grade if unstructured_grade.present? && DOUBLE_GCSE_GRADES.include?(unstructured_grade)

      find_science_gcse(
        qualifications: qualifications,
        award: ApplicationQualification::SCIENCE_DOUBLE_AWARD,
      ).try(:grade)
    end

    def science_triple_gcse_grade(qualifications)
      unstructured_grade = unstructured_gcse_science_grade_from(qualifications)
      return unstructured_grade if unstructured_grade.present? && not_single_or_double_award?(unstructured_grade)

      science_triple_gcse = find_science_gcse(
        qualifications: qualifications,
        award: ApplicationQualification::SCIENCE_TRIPLE_AWARD,
      )

      return if science_triple_gcse.try(:constituent_grades).blank?

      science_triple_gcse[:constituent_grades].values.map { |hash| hash['grade'] }.join
    end

    def english_unstructured_gcse_grade(qualifications)
      english_unstructured_gcse = find_gcse_english(qualifications)
      return nil if english_unstructured_gcse.try(:constituent_grades).present?

      english_unstructured_gcse.try(:grade)
    end

    def english_structured_gcse_grades(qualifications, subject)
      constituent_grades = constituent_gcse_english_grades_from(qualifications)
      constituent_grades.dig(subject, 'grade')
    rescue StandardError
      nil
    end

    def english_other_gcse_grade(qualifications)
      constituent_grades = constituent_gcse_english_grades_from(qualifications)
      constituent_grades.each do |subject, hash|
        return hash['grade'] if ENGLISH_GCSE_SUBJECTS.exclude?(subject)
      end
    rescue StandardError
      nil
    end

    def a_levels(qualifications)
      qualifications
        .select { |qualification| qualification.qualification_type == 'A level' || qualification.qualification_type == 'AS level' }
        .reject(&:incomplete_other_qualification?)
        .take(5)
    end

    def degrees(qualifications)
      qualifications.select(&:degree?).reject(&:incomplete_degree_information?).take(2)
    end

    def other_qualification_count(qualifications)
      qualifications.select(&:other?).size
    end

    def not_single_or_double_award?(unstructured_grade)
      SINGLE_GCSE_GRADES.exclude?(unstructured_grade) && DOUBLE_GCSE_GRADES.exclude?(unstructured_grade)
    end

    def constituent_gcse_english_grades_from(qualifications)
      find_gcse_english(qualifications).constituent_grades
    end

    def unstructured_gcse_science_grade_from(qualifications)
      qualifications.find { |qualification| qualification.gcse? && qualification.subject == 'science' }.try(:grade)
    end

    def find_gcse_english(qualifications)
      qualifications.find { |qualification| qualification.gcse? && qualification.subject == 'english' }
    end

    def find_science_gcse(qualifications:, award:)
      qualifications.find { |qualification| qualification.gcse? && qualification.subject == award }
    end

    ENGLISH_GCSE_SUBJECTS = %w[
      english_single_award
      english_double_award
      english_language
      english_literature
      english_studies_single_award
      english_studies_double_award
    ].freeze
  end
end
