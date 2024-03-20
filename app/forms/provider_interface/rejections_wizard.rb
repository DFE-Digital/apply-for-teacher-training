module ProviderInterface
  class RejectionsWizard
    include Wizard

    validate :valid_rejection_reasons

    class << self
      def rejection_reasons
        @rejection_reasons ||= RejectionReasons.from_config
      end

      delegate  :attribute_names,
                :collection_attribute_names,
                :single_attribute_names,
                :reasons,
                to: :rejection_reasons

      def selectable_reasons
        reasons.reject(&:deprecated?)
      end
    end

    attr_accessor(*attribute_names)

    def sanitize_attrs(attrs)
      reset_deselected_attrs(attrs)
    end

    def initialize_extra(_attrs)
      @checking_answers = true if current_step == 'check'
    end

    def next_step
      'check'
    end

    def object
      RejectionReasons.inflate(self)
    end

    def valid_rejection_reasons
      rejection_reasons = object
      errors.merge!(rejection_reasons.errors) unless rejection_reasons.valid?
    end

    def reset_deselected_attrs(attrs)
      return attrs unless attrs[:current_step] == 'new' && attrs.key?(:selected_reasons)

      self.class.reasons.each do |reason|
        reset_deselected_reason!(attrs, reason)
        reset_deselected_nested_reasons!(attrs, reason)
      end

      attrs
    end

    def reset_deselected_reason!(attrs, reason)
      if attrs[:selected_reasons].exclude?(reason.id)
        attrs[reason.selected_reasons_attr_name] = [] if reason.reasons
        attrs[reason.details.id] = nil if reason.details
      end
    end

    def reset_deselected_nested_reasons!(attrs, reason)
      deselected_nested_reasons(attrs, reason).each do |nested_reason|
        attrs[nested_reason.details.id] = nil if nested_reason.details
      end
    end

    def deselected_nested_reasons(attrs, reason)
      return [] unless reason.reasons

      reason.reasons.select { |nr| attrs[reason.selected_reasons_attr_name].exclude?(nr.id) }
    end
  end
end
