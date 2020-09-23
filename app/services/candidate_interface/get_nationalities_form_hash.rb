module CandidateInterface
  class GetNationalitiesFormHash
    def initialize(application_form:)
      @application_form = application_form
    end

    def call
      {
        nationalities: [set_british_attribute, set_irish_attribute, set_other_attribute].compact,
        british: set_british_attribute,
        irish: set_irish_attribute,
        other: set_other_attribute,
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

    def set_other_attribute
      other_nationalities.present? ? 'other' : nil
    end

    def other_nationalities
      @application_form.nationalities.reject { |nationality| %w[British Irish].include?(nationality) }
    end
  end
end
