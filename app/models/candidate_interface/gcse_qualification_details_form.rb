module CandidateInterface
  class GcseQualificationDetailsForm
    include ActiveModel::Model

    attr_accessor :grade, :award_year, :qualification_id
    validates :grade, :award_year, :qualification_id, presence: true
    validate :validate_award_year_is_date, if: :award_year

    def self.build_from_qualification(qualification)
      new(
        grade: qualification.grade,
        award_year: qualification.award_year,
        qualification_id: qualification.id,
        )
    end

    def save_base
      return false unless valid?

      qualification = ApplicationQualification.find(qualification_id)

      qualification.update(grade: grade, award_year: award_year)
    end

  private

    def validate_award_year_is_date
      valid_award_year = award_year.match(/^[1-9]\d{3}$/)
      errors.add(:award_year, :invalid) unless valid_award_year
    end

  private

    def award_year_is_date
      valid_award_year = award_year.match(/^[1-9]\d{3}$/)
      errors.add(:award_year, :invalid) unless valid_award_year
    end
  end
end
