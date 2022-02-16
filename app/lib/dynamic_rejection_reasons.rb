module DynamicRejectionReasons
  CONFIG_FILE_PATH = 'config/rejection_reasons.yml'.freeze

  def initialize_dynamic_rejection_reasons
    init_attrs
  end

  def configuration
    @configuration ||= YAML.load_file(CONFIG_FILE_PATH)
  end

  def init_attrs
    questions.each do |question_key, question_config|
      attr_accessor question_key

      next unless question_config.key?('reasons')

      define_reasons_collection_methods(question_key)

      define_reasons_attr_accessors(question_config['reasons'])
    end
  end

  def define_reasons_collection_methods(question_key)
    reasons_collection_attr = :"#{question_key}_reasons"

    attr_writer reasons_collection_attr

    define_method reasons_collection_attr do
      instance_variable_get("@#{reasons_collection_attr}") || []
    end
  end

  def define_reasons_attr_accessors(reasons)
    reasons.each do |reason_key, reason_config|
      attr_accessor reason_key
      if reason_config.key?('details')
        attr_accessor :"#{reason_key}_details"
      end
    end
  end

  def questions
    configuration['questions']
  end
end
