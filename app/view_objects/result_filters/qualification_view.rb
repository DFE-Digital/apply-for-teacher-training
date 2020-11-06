module ResultFilters
  class QualificationView
    def initialize(params:)
      @qualifications_parameter = params[:qualifications]
    end

    def qts_only_checked?
      checked?("QtsOnly")
    end

    def pgde_pgce_with_qts_checked?
      checked?("PgdePgceWithQts")
    end

    def other_checked?
      checked?("Other")
    end

    def qualification_selected?
      return false if qualifications_parameter.nil?

      qualifications_parameter.any?
    end

  private

    attr_reader :qualifications_parameter

    def checked?(param_value)
      return false if qualifications_parameter.nil?

      param_value.in?(qualifications_parameter)
    end
  end
end
