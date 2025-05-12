module EqualityAndDiversity
  class ValuesChecker
    def initialize(application_form:, recruitment_cycle_year: RecruitmentCycleTimetable.current_year)
      @initial_values = application_form.equality_and_diversity&.transform_keys(&:to_sym)
      @hesa_converter = HesaConverter.new(application_form:, recruitment_cycle_year:)
    end

    def check_values
      initial_values.present? && unconvertable_data.empty?
    end

  private

    attr_reader :initial_values, :hesa_converter

    def unconvertable_data
      @unconvertable_data ||=
        {
          sex: hesa_converter.hesa_sex,
          disabilities: hesa_converter.hesa_disabilities,
          ethnic_background: hesa_converter.hesa_ethnicity,
          ethnic_group:,
        }.filter do |_field_name, converted_value|
          converted_value.blank?
        end.keys
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
