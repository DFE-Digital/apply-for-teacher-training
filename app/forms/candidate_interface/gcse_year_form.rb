module CandidateInterface
  class GcseYearForm
    include ActiveModel::Model

    attr_accessor :award_year, :qualification_type

    validates :award_year, presence: true, year: { future: true }
    validates :award_year, o_level_award_year: true, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }

    def self.build_from_qualification(qualification)
      new(
        qualification_type: qualification.qualification_type,
        award_year: qualification.award_year,
      )
    end

    def save(qualification)
      return false unless valid?

      qualification.update!(award_year:)
    end
  end
end
