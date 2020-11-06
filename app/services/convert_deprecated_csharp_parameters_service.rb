class ConvertDeprecatedCsharpParametersService
  def call(parameters:)
    boolean_parameter_names = %w[fulltime hasvacancies parttime senCourses]
    array_parameter_names = %w[qualifications subjects]

    have_legacy_params = false
    params_hash = parameters

    boolean_parameter_names.each do |parameter_name|
      if is_legacy_boolean?(parameters[parameter_name])
        have_legacy_params = true
        params_hash = params_hash.merge(parameter_name => legacy_to_rails_boolean(parameters[parameter_name]))
      end
    end

    array_parameter_names.each do |parameter_name|
      if is_legacy_array?(parameters[parameter_name])
        params_hash = params_hash.merge(parameter_name => legacy_to_rails_array(parameters[parameter_name]))
        have_legacy_params = true
      end
    end

    if have_legacy_params
      warn "The user navigated to the results page using the deprecated C# parameterisation scheme" if Rails.env.production?
      return { deprecated: true, parameters: params_hash }
    end

    { deprecated: false, parameters: params_hash }
  end

private

  def is_legacy_boolean?(parameter)
    parameter.in?(%w[True False])
  end

  def is_legacy_array?(parameter)
    parameter.present? && !parameter.instance_of?(Array)
  end

  def legacy_to_rails_array(array)
    if array.instance_of?(String)
      array.split(",")
    elsif array.is_a?(Hash)
      array.values
    end
  end

  def legacy_to_rails_boolean(boolean)
    boolean == "True"
  end
end
