module EqualityAndDiversity
  class ValuesBuilder
    EqualityAndDiversityValuesStruct = Struct.new(:equality_and_diversity_completed, :equality_and_diversity)
    def initialize(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year)
      @recruitment_cycle_year = recruitment_cycle_year
      @values_checker = ValuesChecker.new(application_form:, recruitment_cycle_year:)
    end

    def call
      EqualityAndDiversityValuesStruct.new(
        equality_and_diversity_completed: true,
        equality_and_diversity: converted_equality_and_diversity,
      )
    end

    attr_reader :recruitment_cycle_year, :values_checker

  private

    def converted_equality_and_diversity
      values_checker.converted_equality_and_diversity
    end

    def initial_values
      values_checker.initial_values
    end
  end
end
