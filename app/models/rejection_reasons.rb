class RejectionReasons
  CONFIG_PATH = 'config/rejection_reasons.yml'.freeze

  attr_reader :reasons

  def initialize(config: configuration)
    @reasons = config[:reasons].map { |hash| Reason.new(hash) }
  end

private

  def configuration
    @configuration ||= YAML.load_file(CONFIG_PATH)
  end
end
