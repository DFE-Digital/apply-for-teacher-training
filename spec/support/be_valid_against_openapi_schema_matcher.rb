class ValidAgainstOpenAPISchemaMatcher
  def initialize(schema_name, open_api_3_spec)
    @schema_name = schema_name
    @spec = open_api_3_spec
  end

  def matches?(target)
    @target = target
    validator(@target).valid?
  end

  def failure_message
    validator(@target).failure_message
  end

private

  def validator(target)
    spec = OpenAPI3Specification.new(@spec)

    JSONSchemaValidator.new(
      spec.as_json_schema(@schema_name),
      target,
    )
  end
end
