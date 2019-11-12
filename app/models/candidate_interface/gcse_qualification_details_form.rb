module CandidateInterface
  class GcseQualificationDetailsForm
    include ActiveModel::Model

    attr_accessor :grade, :award_year, :qualification_id
    validates :grade, :award_year, :qualification_id, presence: true
    validate :validate_award_year, if: :award_year
    validate :validate_grade_format

    def self.build_from_qualification(qualification)
      new(
        grade: qualification.grade,
        award_year: qualification.award_year,
        qualification_id: qualification.id,
        )
    end

    def save_base
      return false unless valid?

      qualification.update(grade: grade, award_year: award_year)
    end

  private
    def validate_award_year
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

    def qualification
      @qualification ||= ApplicationQualification.find(qualification_id)
    end

    def invalid_grades
      {
        gcse: /[^1-9A-GU\*]/i,
        gce_o_level: /[^A-EU]/i,
        scottish_higher: /[^A-D1-7]/i,
      }
    end

    def new_record?
      qualification_id.nil?
    end
  end
end
