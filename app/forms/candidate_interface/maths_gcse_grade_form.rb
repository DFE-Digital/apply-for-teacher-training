module CandidateInterface
  class MathsGcseGradeForm
    include ActiveModel::Model

    attr_accessor :grade, :qualification_type, :other_grade
    validates :grade, :qualification_type, presence: true
    validates :other_grade, presence: true, if: :grade_is_other?
    validate :validate_grade_format

    Grade = Struct.new(:value, :option)

    def self.all_grade_drop_down_options
      ALL_GCSE_GRADES.map { |g| Grade.new(g, g) }.unshift(Grade.new(nil, nil))
    end

    def self.build_from_qualification(qualification)
      if qualification.qualification_type == 'non_uk'
        new(
          grade: qualification.set_grade,
          other_grade: qualification.set_other_grade,
          qualification_type: qualification.qualification_type,
        )
      else
        new(
          grade: qualification.grade,
          qualification_type: qualification.qualification_type,
        )
      end
    end

    def save(qualification)
      if valid?
        qualification.update!(grade: set_grade)
        reset_missing_explanation!(qualification)
      else
        log_validation_errors(:grade)
        false
      end
    end

  private

    def validate_grade_format
      return if errors.present? || %w[other_uk non_uk].include?(qualification_type)

      if qualification_type == 'gcse'
        errors.add(:grade, :invalid) unless SINGLE_GCSE_GRADES.include?(sanitize(grade))
      else
        qualification_rexp = invalid_grades[qualification_type.to_sym]

        errors.add(:grade, :invalid) if qualification_rexp && grade.match(qualification_rexp)
      end
    end

    def sanitize(grade)
      grade&.delete(' ')&.upcase
    end

    def invalid_grades
      {
        gcse: /[^1-9A-GU*\s\-]/i,
        gce_o_level: /[^A-EU\s\-]/i,
        scottish_national_5: /[^A-D1-7\s\-]/i,
      }
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

    def grade_is_other?
      grade == 'other'
    end

    def set_grade
      case grade
      when 'other'
        other_grade
      when 'not_applicable'
        'N/A'
      when 'unknown'
        'Unknown'
      else
        sanitize(grade)
      end
    end

    def reset_missing_explanation!(qualification)
      return true unless qualification.pass_gcse?

      qualification.update(missing_explanation: nil)
    end
  end
end
