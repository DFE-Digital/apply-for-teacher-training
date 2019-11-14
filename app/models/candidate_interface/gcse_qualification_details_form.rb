module CandidateInterface
  class GcseQualificationDetailsForm
    include ActiveModel::Model


    attr_accessor :grade, :award_year, :qualification
    validates :grade, :award_year, presence: true
    validate :award_year_is_date, if: :award_year

    validate :validate_grade_format

    def self.build_from_qualification(qualification)
      new(
        grade: qualification.grade,
        award_year: qualification.award_year,
        qualification: qualification,
      )
    end

    def save_base
      return false unless valid?

      qualification.update(grade: grade, award_year: award_year)
    end

  private

    def award_year_is_date
      valid_award_year = award_year.match(/^[1-9]\d{3}$/)
      errors.add(:award_year, :invalid) unless valid_award_year
    end

    def validate_grade_format
      return if new_record? || qualification.qualification_type.nil?

      qualification_rexp = invalid_grades[qualification.qualification_type.to_sym]

      if qualification_rexp && grade.match(qualification_rexp)
        errors.add(:grade, :invalid)
      end
    end

    def invalid_grades
      {
        gcse: /[^1-9A-GU\*\s\-]/i,
        gce_o_level: /[^A-EU\s\-]/i,
        scottish_national_5: /[^A-D1-7\s\-]/i,
      }
    end

    def new_record?
      qualification.nil?
    end
  end
end
