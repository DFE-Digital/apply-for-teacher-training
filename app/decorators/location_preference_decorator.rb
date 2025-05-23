class LocationPreferenceDecorator < SimpleDelegator
  def decorated_name
    if provider.present?
      "#{name} (#{provider.name})"
    else
      name
    end
  end
end
