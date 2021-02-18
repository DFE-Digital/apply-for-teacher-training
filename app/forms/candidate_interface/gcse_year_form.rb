module CandidateInterface
  class GcseYearForm
    include ActiveModel::Model

    attr_accessor :award_year, :qualification_type

    validates :award_year, presence: true, year: true
    validate :award_year_is_a_valid_date, unless: ->(c) { c.errors.keys.include?(:award_year) }

    def self.build_from_qualification(qualification)
      new(
        qualification_type: qualification.qualification_type,
        award_year: qualification.award_year,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(award_year: award_year)
    end

  private

    def award_year_is_not_in_the_future
      date_limit = Time.zone.now.year.to_i + 1
      errors.add(:award_year, :in_future, date: date_limit) if award_year.to_i >= date_limit
    end

    def gce_award_year_is_not_after_1988
      errors.add(:award_year, :gce_o_level_in_future, date: 1989) if award_year.to_i > 1988
    end

    def award_year_is_a_valid_date
      if qualification_type == 'gce_o_level'
        gce_award_year_is_not_after_1988
      else
        award_year_is_not_in_the_future
      end
    end
  end
end
