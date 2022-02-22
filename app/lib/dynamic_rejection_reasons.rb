class RejectionReasonsValidator < ActiveModel::Validator
  def validate(record)
    questions = DynamicRejectionReasons::Questions.from_model(record)
    record.errors.merge!(questions.errors) unless questions.valid?
  end
end

module DynamicRejectionReasons
  CONFIG_FILE_PATH = 'config/rejection_reasons.yml'.freeze

  attr_accessor :attribute_names, :array_attribute_names

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
    configuration.sections.each do |section|
      define_attr(section.id.to_sym, section.details)

      next if section.reasons.blank? || section.reasons.empty?

      define_reasons_collection_methods(section)

      define_reasons_attr_accessors(section.reasons)
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

  def define_reasons_collection_methods(section)
    attr_writer section.reasons_id.to_sym
    @array_attribute_names << section.reasons_id.to_sym

    define_method section.reasons_id do
      instance_variable_get("@#{section.reasons_id}") || []
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

  class Questions
    include ActiveModel::Model
    attr_accessor :sections, :selected_sections

    validate :sections_selected

    def self.from_model(model)
      instance = new
      instance.selected_sections = model.class.configuration.sections.select { |q| model.send(q.id).include?('Yes') }
      instance.selected_sections.each do |section|
        section.details.text = model.send(section.details.id) if section.details
        section.selected_reasons = section.reasons&.select { |r| model.send(section.reasons_id).include?(r.id) }
        section.selected_reasons&.each do |reason|
          reason.details.text = model.send(reason.details.id)
        end
      end
      instance
    end

    def sections_selected
      errors.add(:base, 'Please select a reason') if selected_sections && selected_sections.empty?
    end

    def valid?
      super && valid_children?
    end

    def valid_children?
      selected_sections.map(&:valid?).all?(true)
    end

    def errors
      return super if selected_sections.blank?

      selected_sections.map(&:errors).each { |errors| super.merge!(errors) if errors.respond_to?(:errors) }

      super
    end
  end

  class Question
    include ActiveModel::Model
    attr_accessor :id, :details, :label, :reasons_id, :reasons, :selected_reasons

    validate :reasons_selected

    def reasons_selected
      errors.add(reasons_id, 'Please select a reason') if selected_reasons && selected_reasons.empty?
    end

    def valid?
      super && valid_children?
    end

    def valid_children?
      return true unless details || reasons

      if details
        details.valid?
      else
        selected_reasons.map(&:valid?).all?(true)
      end
    end

    def errors
      return super unless details || reasons

      if details
        super.merge!(details.errors)
      else
        selected_reasons.map(&:errors).each { |errors| super.merge!(errors) if errors.respond_to?(:errors) }
      end

      super
    end
  end

  class Reason
    include ActiveModel::Model
    attr_accessor :id, :details, :label

    def valid?
      super && valid_children?
    end

    def valid_children?
      return true unless details

      details.valid?
    end

    def errors
      super.merge!(details&.errors)
      super
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
