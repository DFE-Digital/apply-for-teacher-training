module CandidateInterface
  class EnglishGcseGradeForm
    include ActiveModel::Model
    include EnglishGcseGradeAttributeBuilder

    attr_accessor :grade,
                  :qualification,
                  :other_grade,
                  :constituent_grades,
                  :english_gcses,
                  :english_single_award,
                  :grade_english_single,
                  :english_double_award,
                  :grade_english_double,
                  :english_language,
                  :grade_english_language,
                  :english_literature,
                  :grade_english_literature,
                  :english_studies_single_award,
                  :grade_english_studies_single,
                  :english_studies_double_award,
                  :grade_english_studies_double,
                  :other_english_gcse,
                  :other_english_gcse_name,
                  :grade_other_english_gcse,
                  :award_year

    validates :grade, presence: true, on: :grade
    validates :other_grade, presence: true, if: :grade_is_other?
    validate :validate_grade_format, on: :grade, unless: :multiple_gcse? || :new_record?
    validate :validate_grades_format, on: :constituent_grades, if: :multiple_gcse?, unless: :new_record?
    validate :gcse_selected, on: :constituent_grades, if: :multiple_gcse?

    class << self
      def build_from_qualification(qualification)
        if qualification.qualification_type == 'non_uk'
          new(grade: qualification.set_grade,
              other_grade: qualification.set_other_grade,
              qualification:)
        else
          new(build_params_from(qualification))
        end
      end
    end

    def save
      result = multiple_gcse? ? save_grades : save_grade
      return false unless result

      reset_missing_and_not_completed_explanations!(qualification)
      result
    end

    def save_grade
      if !valid?(:grade)
        log_validation_errors(:grade)
        return false
      end
      qualification.update(grade: set_grade, constituent_grades: nil)
    end

    def save_grades
      if !valid?(:constituent_grades)
        log_validation_errors(:constituent_grades)
        return false
      end
      qualification.update(constituent_grades: build_grades_json, grade: nil)
    end
  end
end
