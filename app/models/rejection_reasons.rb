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
    (nested_reasons + details).map(&:id).map(&:to_sym)
  end

  def collection_attribute_names
    reasons.map { |r| [r.id, r.reasons_id].compact }.flatten.map(&:to_sym)
  end

  def attribute_names
    single_attribute_names + collection_attribute_names
  end

  def nested_reasons
    reasons.map(&:reasons).flatten.compact
  end

  def details
    (reasons + nested_reasons).map(&:details).compact
  end
end
