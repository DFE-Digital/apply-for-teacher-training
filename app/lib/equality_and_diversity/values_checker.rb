module EqualityAndDiversity
  class ValuesChecker
    def initialize(application_form:, recruitment_cycle_year: RecruitmentCycle.current_year)
      @initial_values = application_form.equality_and_diversity&.transform_keys(&:to_sym)
      @recruitment_cycle_year = recruitment_cycle_year
      @hesa_converter = HesaConverter.new(application_form:, recruitment_cycle_year:)
    end

    def check
      initial_values.present? && unconvertable_data.empty?
    end

    def converted_equality_and_diversity
      if check
        @initial_values.merge(
          hesa_sex: @hesa_converter.hesa_sex,
          sex: @hesa_converter.sex,
          hesa_disabilities: @hesa_converter.hesa_disabilities,
          disabilities: @hesa_converter.disabilities,
          hesa_ethnicity: @hesa_converter.hesa_ethnicity,
          ethnic_group:,
        )
      else
        raise UnexpectedValuesError, error_message
      end
    end

    attr_reader :initial_values

  private

    def unconvertable_data
      @unconvertable_data ||=
        {
          sex: @hesa_converter.hesa_sex,
          disabilities: @hesa_converter.hesa_disabilities,
          ethnic_background: @hesa_converter.hesa_ethnicity,
          ethnic_group:,
        }.filter do |_field_name, converted_value|
          converted_value.blank?
        end.keys
    end

    def error_message
      if @initial_values.present?
        "The answer(s) for #{unconvertable_data.to_sentence} cannot be converted to HESA values for #{@recruitment_cycle_year}"
      else
        'No equality and diversity information provided'
      end
    end

    def ethnic_group
      @ethnic_group ||= if @initial_values[:ethnic_group].blank? && @initial_values[:ethnic_background] == 'Prefer not to say'
                          'Prefer not to say'
                        else
                          @initial_values[:ethnic_group]
                        end
    end
  end
end
