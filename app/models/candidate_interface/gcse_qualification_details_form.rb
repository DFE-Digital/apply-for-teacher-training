module CandidateInterface
  class GcseQualificationDetailsForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :grade, :award_year, :qualification
    validates :grade, presence: true, on: :grade
    validates :award_year, presence: true, on: :award_year
    validates :grade, length: { maximum: 6 }, on: :grade
    validate :award_year_is_date, if: :award_year, on: :award_year

    validate :validate_grade_format, unless: :new_record?, on: :grade

    def self.build_from_qualification(qualification)
      new(
        grade: qualification.grade,
        award_year: qualification.award_year,
        qualification: qualification,
      )
    end

    def save_grade
      if !valid?(:grade)
        log_validation_errors(:grade)
        return false
      end

      qualification.update(grade: grade, award_year: award_year)
    end

    def save_year
      if valid?(:award_year)
        qualification.update(grade: grade, award_year: award_year)
        return true
      end

      false
    end

  private

    def award_year_is_date
      valid_award_year = valid_year?(award_year)
      errors.add(:award_year, :invalid) unless valid_award_year
    end

    def validate_grade_format
      return if qualification.qualification_type.nil? || qualification.qualification_type == 'other_uk'

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

    def log_validation_errors(field)
      return unless errors.key?(field)

      error_message = {
        field: field.to_s,
        error_messages: errors[field].join(' - '),
        value: instance_values[field.to_s],
      }

      Rails.logger.info("Validation error: #{error_message.inspect}")
    end
  end
end
