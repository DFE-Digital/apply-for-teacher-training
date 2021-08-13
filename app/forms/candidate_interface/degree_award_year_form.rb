module CandidateInterface
  class DegreeAwardYearForm
    include ActiveModel::Model

    attr_accessor :award_year, :degree

    validates :award_year, year: true, presence: true
    validate :award_year_is_before_the_end_of_next_year, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }
    validate :award_year_is_in_the_future_for_incomplete_degree, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }
    validate :award_year_is_before_training_starts, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }

    def save
      return false unless valid?

      degree.update!(award_year: award_year)
    end

    def assign_form_values
      self.award_year = degree.award_year
      self
    end

  private

    def award_year_is_in_the_future_for_incomplete_degree
      errors.add(:award_year, :in_the_future) if degree.start_year.present? && degree.predicted_grade? && award_year.to_i < RecruitmentCycle.current_year
    end

    def award_year_is_before_the_end_of_next_year
      upper_year_limit = RecruitmentCycle.current_year + 10

      errors.add(:award_year, :greater_than_limit, date: upper_year_limit) if award_year.to_i >= upper_year_limit
    end

    def award_year_is_before_training_starts
      errors.add(:award_year, :in_time_for_training) if degree.predicted_grade? && award_year.to_i > RecruitmentCycle.current_year
    end
  end
end
