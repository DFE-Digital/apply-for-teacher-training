class RouteExtension
  def initialize(context)
    @context = context
  end

  # rubocop:disable Style/MethodMissingSuper
  # rubocop:disable Style/MissingRespondToMissing
  def method_missing(name, *args, &block)
    @context.send(name, *args, &block)
  end
  # rubocop:enable Style/MethodMissingSuper
  # rubocop:enable Style/MissingRespondToMissing
end
