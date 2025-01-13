module SupportInterface
  class QualificationsExport
    def data_for_export(*)
      ExpandedQualificationsExport.new.data_for_export
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
        qualifications:,
        award: ApplicationQualification::SCIENCE_SINGLE_AWARD,
      ).try(:grade)
    end

    def science_double_gcse_grade(qualifications)
      unstructured_grade = unstructured_gcse_science_grade_from(qualifications)
      return unstructured_grade if unstructured_grade.present? && DOUBLE_GCSE_GRADES.include?(unstructured_grade)

      find_science_gcse(
        qualifications:,
        award: ApplicationQualification::SCIENCE_DOUBLE_AWARD,
      ).try(:grade)
    end

    def science_triple_gcse_grade(qualifications)
      unstructured_grade = unstructured_gcse_science_grade_from(qualifications)
      return unstructured_grade if unstructured_grade.present? && not_single_or_double_award?(unstructured_grade)

      science_triple_gcse = find_science_gcse(
        qualifications:,
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
        .select { |qualification| ['A level', 'AS level'].include?(qualification.qualification_type) }
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
