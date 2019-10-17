module VendorApiSpecHelpers
  VALID_METADATA = {
    attribution: {
      full_name: 'Jane Smith',
      email: 'jane@example.com',
      user_id: '12345',
    },
    timestamp: Time.now.iso8601,
  }.freeze

  def get_api_request(url, options = {})
    get url, auth_headers.deep_merge(options)
  end

  def post_api_request(url, options = {})
    post url, { params: { meta: VALID_METADATA } }.merge(auth_headers).deep_merge(options)
  end

  def auth_headers
    unhashed_token = VendorApiToken.create_with_random_token!(provider: currently_authenticated_provider)
    { headers: { 'Authorization' => "Bearer #{unhashed_token}" } }
  end

  def currently_authenticated_provider(code: 'UCL')
    @currently_authenticated_provider ||= create(:provider, code: code)
  end

  def alternate_provider(code: 'STR')
    @alternate_provider ||= create(:provider, code: code)
  end

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
