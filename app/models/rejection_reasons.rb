class RejectionReasons
  include ActiveModel::Model
  CONFIG_PATH = 'config/rejection_reasons.yml'.freeze

  attr_accessor :reasons, :selected_reasons

  validate :reasons_selected

  class << self
    def from_config(config: configuration)
      instance = new
      instance.reasons = config[:reasons].map { |rattrs| Reason.new(rattrs) }
      instance
    end

    def inflate(model)
      instance = new
      instance.selected_reasons = from_config.reasons.dup
        .select { |r| model.send(:selected_reasons)&.include?(r.id) }
        .map { |reason| reason.inflate(model) }
      instance
    end

    def configuration
      @configuration ||= YAML.load_file(CONFIG_PATH)
    end
  end

  def single_attribute_names
    details.map(&:id).map(&:to_sym)
  end

  def collection_attribute_names
    [:selected_reasons] + reasons
      .select { |r| r.reasons.present? }
      .map(&:selected_reasons_attr_name)
  end

  def attribute_names
    single_attribute_names + collection_attribute_names
  end

  def reasons_selected
    errors.add(:base, 'Please select a reason') if selected_reasons && selected_reasons.empty?
  end

  def valid?
    super && valid_children?
  end

  def valid_children?
    selected_reasons.map(&:valid?).all?(true)
  end

  def errors
    return super if selected_reasons.blank?

    selected_reasons.map(&:errors).each { |errors| super.merge!(errors) }

    super
  end

  def nested_reasons
    reasons.map(&:reasons).flatten.compact
  end

  def details
    (reasons + nested_reasons).map(&:details).compact
  end
end
