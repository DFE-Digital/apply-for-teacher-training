class DeprecatedParametersService
  def initialize(parameters:)
    @original_parameters = parameters
    @csharp_parameter_converter = ConvertDeprecatedCsharpParametersService.new.call(parameters: params_hash)
  end

  def deprecated?
    csharp_parameter_converter[:deprecated] || legacy_params_values?
  end

  def parameters
    if deprecated?
      csharp_parameter_converter[:parameters]
    else
      params_hash
    end
  end

private

  def legacy_params_values?
    @legacy_params_values ||= original_parameters.key?("rad") && original_parameters["rad"] != ResultsView::MILES
  end

  def params_hash
    if legacy_params_values?
      original_parameters["rad"] = ResultsView::MILES

      if original_parameters.key? "page"
        original_parameters["page"] = 1
      end
    end
    original_parameters
  end

  attr_reader :original_parameters, :csharp_parameter_converter
end
