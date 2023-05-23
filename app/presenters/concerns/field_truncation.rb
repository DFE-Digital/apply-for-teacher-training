module FieldTruncation
  OMISSION_TEXT = '... (this field was truncated as it went over the length limit)'.freeze

private

  def truncate_if_over_advertised_limit(field_name, field_value)
    limit = field_length(field_name)
    return field_value if field_value.nil?
    return field_value if field_value.length <= limit

    field_value.truncate(limit, omission: OMISSION_TEXT)
  end

  def field_length(name)
    RetrieveAPIFieldLength.new(name).call
  end
end
