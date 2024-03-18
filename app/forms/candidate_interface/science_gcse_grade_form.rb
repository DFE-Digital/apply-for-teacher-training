module CandidateInterface
  class ScienceGcseGradeForm
    include ActiveModel::Model
    include ScienceGcseHelper

    attr_accessor :grade,
                  :constituent_grades,
                  :award_year,
                  :qualification,
                  :subject,
                  :other_grade,
                  :single_award_grade,
                  :double_award_grade,
                  :gcse_science,
                  :biology_grade,
                  :physics_grade,
                  :chemistry_grade
    validates :other_grade, presence: true, if: :grade_is_other?
    validates :other_grade, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_GRADE_LENGTH }
    validates :grade, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_GRADE_LENGTH }
    validate :grade_length
    validate :grade_format, unless: :new_record?
    validate :triple_award_grade_format

    class << self
      def build_from_qualification(qualification)
        if qualification.qualification_type == 'non_uk'
          new(
            grade: qualification.set_grade,
            other_grade: qualification.set_other_grade,
            qualification:,
          )
        else
          new(build_params_from(qualification))
        end
      end

    private

      def build_params_from(qualification)
        params = {
          gcse_science: qualification.subject,
          subject: qualification.subject,
          qualification:,
          award_year: qualification.award_year,
        }

        case qualification.subject
        when ApplicationQualification::SCIENCE_SINGLE_AWARD
          params[:single_award_grade] = qualification.grade
        when ApplicationQualification::SCIENCE_DOUBLE_AWARD
          params[:double_award_grade] = qualification.grade
        when ApplicationQualification::SCIENCE_TRIPLE_AWARD
          grades = qualification.constituent_grades
          return unless grades

          params[:biology_grade] = grades['biology']['grade']
          params[:chemistry_grade] = grades['chemistry']['grade']
          params[:physics_grade] = grades['physics']['grade']
        else
          params[:grade] = qualification.grade
        end

        params
      end
    end

    def save
      unless valid?
        log_validation_errors(errors.attribute_names.first)
        return false
      end

      return false unless qualification.update(
        grade: set_grade,
        constituent_grades: set_triple_award_grades,
        subject:,
      )

      reset_missing_and_not_completed_explanations!(qualification)
    end

    def assign_values(params)
      self.gcse_science = params[:gcse_science]
      self.grade = grade_from(params)
      self.other_grade = params[:other_grade]
      self.subject = params[:gcse_science] || ApplicationQualification::SCIENCE
      self.biology_grade = params[:biology_grade]
      self.chemistry_grade = params[:chemistry_grade]
      self.physics_grade = params[:physics_grade]
      self
    end
  end
end
