class RejectionReasons
  include ActiveModel::Model
  CONFIG_PATH = 'config/rejection_reasons.yml'.freeze

  attr_accessor :reasons, :selected_reasons

  def self.from_config(config: YAML.load_file(CONFIG_PATH))
    instance = new
    instance.reasons = config[:reasons].map { |rattrs| Reason.new(rattrs) }
    instance
  end

  def single_attribute_names
    reasons.map(&:single_attribute_names).flatten.sort
  end

  def collection_attribute_names
    reasons.map(&:collection_attribute_names).flatten.sort
  end

  def attribute_names
    (single_attribute_names + collection_attribute_names).sort
  end
end
