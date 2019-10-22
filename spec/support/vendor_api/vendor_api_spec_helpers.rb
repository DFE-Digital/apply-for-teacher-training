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
    get url, {
      headers: {
        'Authorization' => auth_header,
      },
    }.deep_merge(options)
  end

  def post_api_request(url, options = {})
    headers_and_params = {
      params: {
        meta: VALID_METADATA,
      },
      headers: {
        'Authorization' => auth_header,
        'Content-Type' => 'application/json',
      },
    }.deep_merge(options)

    headers_and_params[:params] = headers_and_params[:params].to_json

    post url, headers_and_params
  end

  def auth_header
    unhashed_token = VendorApiToken.create_with_random_token!(provider: currently_authenticated_provider)
    "Bearer #{unhashed_token}"
  end

  def currently_authenticated_provider
    @currently_authenticated_provider ||= create(:provider)
  end

  def create_application_choice_for_currently_authenticated_provider(attributes = {})
    create(
      :application_choice,
      { course_option: course_option_for_provider(provider: currently_authenticated_provider) }.merge(attributes),
    )
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
