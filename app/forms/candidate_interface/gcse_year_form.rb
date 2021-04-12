module CandidateInterface
  class GcseYearForm
    include ActiveModel::Model

    attr_accessor :award_year, :qualification_type

    validates :award_year, presence: true, year: { future: true }
    validate :o_level_award_year_is_a_valid_date, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }

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

    def gce_award_year_is_not_after_1988
      errors.add(:award_year, :gce_o_level_in_future, date: 1989) if award_year.to_i > 1988
    end

    def o_level_award_year_is_a_valid_date
      if qualification_type == 'gce_o_level'
        gce_award_year_is_not_after_1988
      end
    end
  end
end
