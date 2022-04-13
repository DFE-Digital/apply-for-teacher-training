class RejectionReasons
  include ActiveModel::Model
  CONFIG_PATH = 'config/rejection_reasons.yml'.freeze
  TRANSLATION_KEY_PREFIX = 'activemodel.errors.models.provider_interface/rejections_wizard.attributes'.freeze

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

    def translated_error(attr_name, error_type = nil)
      I18n.t([TRANSLATION_KEY_PREFIX, attr_name, error_type].compact.join('.'))
    end
  end

  def initialize(attrs = {})
    attrs.deep_symbolize_keys!

    super(attrs)

    @selected_reasons = attrs[:selected_reasons].map { |rattrs| Reason.new(rattrs) } if attrs.key?(:selected_reasons)
  end

  def find(identifier)
    selected_reasons.find { |reason| reason.id == identifier } ||
      nested_reasons(collection: :selected_reasons).find { |nested_reason| nested_reason.id == identifier } ||
      details(collection: :selected_reasons).find { |details| details.id == identifier }
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
    if selected_reasons && selected_reasons.empty?
      errors.add(:selected_reasons, self.class.translated_error(:selected_reasons))
    end
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

  def nested_reasons(collection: :reasons)
    send(collection).map(&collection).flatten.compact
  end

  def details(collection: :reasons)
    (send(collection) + nested_reasons(collection: collection)).map(&:details).compact
  end
end
