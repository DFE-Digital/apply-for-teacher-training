module VendorApiSpecHelpers
  def parsed_response
    JSON.parse(response.body)
  end

  def error_response
    parsed_response['errors'].first
  end

  RSpec::Matchers.define :be_valid_against_openapi_schema do |schema_name|
    match do |item|
      spec = OpenApi3Specification.new(YAML.load_file("#{Rails.root}/config/vendor-api-0.5.0.yml"))

      JSONSchemaValidator.new(
        spec.as_json_schema(schema_name),
        item,
      ).valid?
    end

    failure_message do |item|
      spec = OpenApi3Specification.new(YAML.load_file("#{Rails.root}/config/vendor-api-0.5.0.yml"))

      JSONSchemaValidator.new(
        spec.as_json_schema(schema_name),
        item,
      ).failure_message
    end
  end

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
      validator.map { |message| '- ' + humanized_error(message) }.join("\n")
    end

    def formatted_item
      return item if item.is_a?(String)

      JSON.pretty_generate(item)
    end

    def humanized_error(message)
      message.gsub("The property '#/'", 'The item')
    end
  end
end
