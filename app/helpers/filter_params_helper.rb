module FilterParamsHelper
  def compact_params(params)
    params.transform_values do |param_value|
      next param_value unless param_value.is_a?(Array)

      param_value.compact_blank
    end
  end
end
