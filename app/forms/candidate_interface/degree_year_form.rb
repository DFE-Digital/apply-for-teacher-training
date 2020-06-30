module CandidateInterface
  class DegreeYearForm
    include ActiveModel::Model
    include ValidationUtils

    attr_accessor :start_year, :award_year, :degree

    validates :start_year, presence: true
    validates :award_year, presence: true
    validate :start_year_is_valid_date, if: :start_year
    validate :award_year_is_valid_date, if: :award_year

    def save
      return false unless valid?

      degree.update!(start_year: start_year, award_year: award_year)
    end

    def fill_form_values
      self.start_year = degree.start_year
      self.award_year = degree.award_year
      self
    end

  private

    def start_year_is_valid_date
      if valid_year?(start_year)
        start_year_is_before_the_award_year
      else
        start_year_is_invalid
      end
    end

    def award_year_is_valid_date
      if valid_year?(award_year)
        award_year_is_before_the_end_of_next_year
      else
        award_year_is_invalid
      end
    end

    def start_year_is_invalid
      errors.add(:start_year, :invalid)
    end

    def award_year_is_invalid
      errors.add(:award_year, :invalid)
    end

    def start_year_is_before_the_award_year
      errors.add(:start_year, :greater_than_award_year, date: award_year) if award_year.present? && award_year.to_i < start_year.to_i
    end

    def award_year_is_before_the_end_of_next_year
      upper_year_limit = Time.zone.now.year.to_i + 2

      errors.add(:award_year, :greater_than_limit, date: upper_year_limit) if award_year.to_i >= upper_year_limit
    end
  end
end
