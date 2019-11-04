module CandidateInterface
  class DegreesForm
    include ActiveModel::Model

    attr_accessor :id, :qualification_type, :subject, :institution_name, :grade,
                  :other_grade, :predicted_grade, :award_year

    validates :qualification_type, :subject, :institution_name, :grade, presence: true
    validates :other_grade, presence: true, if: :other_grade?
    validates :predicted_grade, presence: true, if: :predicted_grade?
    validates :award_year, presence: true

    validates :qualification_type, :subject, :institution_name, :grade, length: { maximum: 255 }
    validates :other_grade, :predicted_grade, length: { maximum: 255 }

    validate :award_year_is_date, if: :award_year

    def self.build_from_application(application_form)
      application_form.application_qualifications.degrees.map do |degree|
        new(
          id: degree.id,
          qualification_type: degree.qualification_type,
          subject: degree.subject,
          institution_name: degree.institution_name,
          grade: degree.grade,
          predicted_grade: degree.predicted_grade,
          award_year: degree.award_year,
        )
      end
    end

    def save_base(application_form)
      return false unless valid?

      application_form.application_qualifications.create!(
        level: ApplicationQualification.levels['degree'],
        qualification_type: qualification_type,
        subject: subject,
        institution_name: institution_name,
        grade: determine_grade,
        predicted_grade: predicted_grade? ? true : false,
        award_year: award_year,
      )

      true
    end

    def title
      "#{qualification_type} #{subject}"
    end

  private

    def other_grade?
      grade == 'other'
    end

    def predicted_grade?
      grade == 'predicted'
    end

    def award_year_is_date
      valid_award_year = award_year.match(/^[1-9]\d{3}$/)
      errors.add(:award_year, :invalid) unless valid_award_year
    end

    def determine_grade
      case grade
      when 'other'
        other_grade
      when 'predicted'
        predicted_grade
      else
        grade
      end
    end
  end
end
