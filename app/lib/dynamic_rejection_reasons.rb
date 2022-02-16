class NestedAnswerValidator < ActiveModel::Validator
  # TODO: I18n this
  def validate(record)
    top_level_answers = []

    record.class.questions.each do |question_key, question_config|
      top_level_answer = record.send(question_key)
      next if top_level_answer.blank? || top_level_answer.compact_blank.empty?

      top_level_answers << top_level_answer

      if question_config.key?('reasons')
        question_config['reasons'].each do |reason_key, reason_config|
          reasons_answers = record.send(:"#{question_key}_reasons")

          if reasons_answers.blank? || reasons_answers.compact_blank.empty?
            record.errors.add(:"#{question_key}_reasons", 'Choose at least one reason')
          end

          next unless reason_config.key?('details')

          validate_details(record, reason_key) if reasons_answers.include?(reason_key)
        end

      end

      next unless question_config.key?('details')

      validate_details(record, question_key)
    end

    record.errors.add(:base, 'Choose at least one reason') if top_level_answers.empty?
  end

  def validate_details(record, key)
    details_attr_name = :"#{key}_details"
    details_answer = record.send(details_attr_name)
    record.errors.add(details_attr_name, 'Please give details') if details_answer.blank?
  end
end

module DynamicRejectionReasons
  CONFIG_FILE_PATH = 'config/rejection_reasons.yml'.freeze

  attr_accessor :attribute_names, :array_attribute_names

  # TODO: A few things to tidy up:
  # - YAML could produce POROs instead of doing Hash lookups
  # - I18n FTW
  # - Conditional reasons (de-scope pls)

  def initialize_dynamic_rejection_reasons
    @attribute_names = []
    @array_attribute_names = []

    init_attrs
    init_validations
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
    @array_attribute_names << attr_name

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

  def init_validations
    validates_with NestedAnswerValidator
  end

  def questions
    configuration['questions']
  end
end
