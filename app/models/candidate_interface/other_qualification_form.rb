module CandidateInterface
  class OtherQualificationForm
    include ActiveModel::Model

    attr_accessor :id, :qualification_type, :subject, :institution_name, :grade,
                  :award_year

    validates :qualification_type, :subject, :institution_name, :grade, :award_year, presence: true

    validates :qualification_type, :subject, :institution_name, :grade, length: { maximum: 255 }

    validate :award_year_is_date_and_before_current_year, if: :award_year

  private

    def award_year_is_date_and_before_current_year
      valid_award_year = award_year.match?(/^[1-9]\d{3}$/)

      if !valid_award_year
        errors.add(:award_year, :invalid)
      elsif Date.new(award_year.to_i, 1, 1).year > Date.today.year
        errors.add(:award_year, :in_the_future)
      end
    end
  end
end
