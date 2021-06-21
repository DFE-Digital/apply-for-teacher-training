class JSONSchemaValidator
  attr_reader :schema, :item

  def initialize(schema, item)
    @schema = schema
    @item = item
  end

  def valid?
    formatted_validation_errors.blank?
  end

  def failure_message
    <<~ERROR
      Expected the item to be valid against schema:

      #{formatted_item}

      But I got these validation errors:

      #{formatted_validation_errors}
    ERROR
  end

private

  def formatted_validation_errors
    validator = JSON::Validator.fully_validate(schema, item)
    validator.map { |message| "- #{humanized_error(message)}" }.join("\n")
  end

  def formatted_item
    return item if item.is_a?(String)

    JSON.pretty_generate(item)
  end

  def humanized_error(message)
    message.gsub("The property '#/'", 'The item')
  end
end
