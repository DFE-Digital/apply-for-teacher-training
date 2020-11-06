class UnescapedQueryStringService
  def initialize(base_path:, parameters:)
    @base_path = base_path
    @parameters = parameters
  end

  class << self
    def call(**args)
      new(args).call
    end
  end

  def call
    "#{base_path}?#{parameters.to_param}".gsub("%2C", ",")
  end

  private_class_method :new

private

  attr_reader :base_path, :parameters
end
