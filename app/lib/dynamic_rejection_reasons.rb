module DynamicRejectionReasons
  CONFIG_FILE_PATH = 'config/rejection_reasons.yml'.freeze

  attr_accessor :attribute_names, :array_attribute_names

  def initialize_dynamic_rejection_reasons
    @attribute_names = []
    @array_attribute_names = []

    init_attrs
  end

  def configuration
    @configuration ||= YAML.load_file(CONFIG_FILE_PATH)
  end

  def init_attrs
    questions.each do |question_key, question_config|
      define_attr(question_key.to_sym, details: question_config.key?('details'))

      next unless question_config.key?('reasons')

      define_reasons_collection_methods(question_key)

      define_reasons_attr_accessors(question_config['reasons'])
    end
  end

  def define_attr(attr_name, details: false)
    attr_accessor attr_name
    @attribute_names << attr_name

    if details
      details_attr_name = :"#{attr_name}_details"
      attr_accessor details_attr_name
      @attribute_names << details_attr_name
    end
  end

  def define_reasons_collection_methods(question_key)
    reasons_collection_attr = :"#{question_key}_reasons"

    attr_writer reasons_collection_attr
    @array_attribute_names << reasons_collection_attr

    define_method reasons_collection_attr do
      instance_variable_get("@#{reasons_collection_attr}") || []
    end
  end

  def define_reasons_attr_accessors(reasons)
    reasons.each do |reason_key, reason_config|
      attr_accessor reason_key.to_sym
      @attribute_names << reason_key.to_sym

      next unless reason_config.key?('details')

      details_attr_name = :"#{reason_key}_details"
      attr_accessor details_attr_name
      @attribute_names << details_attr_name
    end
  end

  def questions
    configuration['questions']
  end
end
