module CandidateInterface
  class DegreeStartYearForm
    include ActiveModel::Model

    attr_accessor :start_year, :degree

    validates :start_year, year: true, presence: true
    validate :start_year_is_after_the_award_year, unless: ->(c) { c.errors.attribute_names.include?(:start_year) }

    def save
      return false unless valid?

      degree.update!(start_year: start_year)
    end

    def assign_form_values
      self.start_year = degree.start_year
      self
    end

  private

    def start_year_is_after_the_award_year
      errors.add(:start_year, :greater_than_award_year, date: degree.award_year) if degree.award_year.present? && degree.award_year.to_i < start_year.to_i
    end
  end
end
