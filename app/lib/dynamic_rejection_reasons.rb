class RejectionReasonsValidator < ActiveModel::Validator
  # TODO: I18n errors
  def validate(record)
#    top_level_answers = []
#
#    record.class.configuration.questions.each do |question|
#      top_level_answer = record.send(question.id)
#      next if top_level_answer.blank? || top_level_answer.compact_blank.empty?
#
#      top_level_answers << top_level_answer
#
#      validate_details(record, question.details) if question.details.present?
#
#      next if question.reasons.blank? || question.reasons.empty?
#
#      question.reasons.each do |reason|
#        reasons_answers = record.send(question.reasons_id)
#
#        if reasons_answers.blank? || reasons_answers.compact_blank.empty?
#          record.errors.add(question.reasons_id.to_sym, 'Choose at least one reason')
#        end
#
#        next if reason.details.blank?
#
#        validate_details(record, reason.details) if reasons_answers.include?(reason.id)
#      end
#    end
#    record.errors.add(:base, 'Choose at least one reason') if top_level_answers.empty?

    DynamicRejectionReasons::Questionnaire.from_model(record)
  end

  def validate_details(record, details)
    details.text = record.send(details.id)
    details.valid?(record)
  end
end

module DynamicRejectionReasons
  CONFIG_FILE_PATH = 'config/rejection_reasons.yml'.freeze

  attr_accessor :attribute_names, :array_attribute_names

  # TODO: A few things to tidy up:
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
    configuration.questions.each do |question|
      define_attr(question.id.to_sym, question.details)

      next if question.reasons.blank? || question.reasons.empty?

      define_reasons_collection_methods(question)

      define_reasons_attr_accessors(question.reasons)
    end
  end

  def define_attr(attr_name, details)
    attr_accessor attr_name
    @array_attribute_names << attr_name

    if details
      attr_accessor details.id.to_sym
      @attribute_names << details.id.to_sym
    end
  end

  def define_reasons_collection_methods(question)
    attr_writer question.reasons_id.to_sym
    @array_attribute_names << question.reasons_id.to_sym

    define_method question.reasons_id do
      instance_variable_get("@#{question.reasons_id}") || []
    end
  end

  def define_reasons_attr_accessors(reasons)
    reasons.each do |reason|
      attr_accessor reason.id.to_sym
      @attribute_names << reason.id.to_sym

      next if reason.details.blank?

      attr_accessor reason.details.id.to_sym
      @attribute_names << reason.details.id.to_sym
    end
  end

  def init_validations
    validates_with RejectionReasonsValidator
  end

  class Questionnaire
    include ActiveModel::Model
    attr_accessor :questions, :selected_questions

    validate :questions_selected

    def self.from_model(model)
      instance = new
      instance.selected_questions = model.class.configuration.questions.select { |q| model.send(q.id).include?('Yes') }
      instance.selected_questions.each do |question|
        question.details.text = model.send(question.details.id) if question.details
        question.selected_reasons = question.reasons&.select { |r| model.send(question.reasons_id).include?(r.id) }
        question.selected_reasons&.each do |reason|
          reason.details.text = model.send(reason.details.id)
        end
      end
      instance
    end

    def questions_selected
      errors.add(question.id, 'Please select a reason') if selected_questions.present? && selected_questions.empty?
    end

    def errors
      super.merge!(selected_questions&.map(&:errors))
    end
  end

  class Question
    include ActiveModel::Model
    attr_accessor :id, :details, :label, :reasons_id, :reasons, :selected_reasons

    validate :reasons_selected

    def reasons_selected
      errors.add(question.reasons_id, 'Please select a reason') if selected_reasons.present? && selected_reasons.empty?
    end

    def errors
      super.merge!(selected_reasons&.map(&:errors)).merge!(details&.errors)
    end
  end

  class Reason
    include ActiveModel::Model
    attr_accessor :id, :details, :label

    def errors
      super.merge!(details&.errors)
    end
  end

  class Details
    include ActiveModel::Model
    WORD_COUNT = 100

    attr_accessor :id, :label, :text, :record
    validate :text_present, :word_count

    def text_present
      errors.add(id, 'Please give details') if text.blank?
    end

    def word_count
      if text.present? && text.scan(/\S+/).size > WORD_COUNT
        errors.add(id, 'Details are too long')
      end
    end
  end
end
