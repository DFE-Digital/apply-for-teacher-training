module CandidateInterface
  class GetNationalitiesFormHash
    def initialize(application_form:)
      @application_form = application_form
    end

    def call
      {
        british: set_british_attribute,
        irish: set_irish_attribute,
        other: other_nationalities.present? ? 'other' : nil,
        other_nationality1: other_nationalities[0],
        other_nationality2: other_nationalities[1],
        other_nationality3: other_nationalities[2],
      }
    end

  private

    def set_british_attribute
      'British' if @application_form.nationalities.include?('British')
    end

    def set_irish_attribute
      'Irish' if @application_form.nationalities.include?('Irish')
    end

    def other_nationalities
      @application_form.nationalities.reject { |nationality| %w[British Irish].include?(nationality) }
    end
  end
end
