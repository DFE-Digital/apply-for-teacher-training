class RejectionReasons
  class Reason
    include ActiveModel::Model

    TRANSLATION_KEY_PREFIX = 'activemodel.errors.models.provider_interface/rejections_wizard.attributes'.freeze

    attr_accessor :id, :deprecated, :details, :label, :reasons, :reasons_visually_hidden, :selected_reasons

    validate :reasons_selected

    def inflate(model)
      @details = details.inflate(model) if details

      if reasons
        @selected_reasons = reasons
          .select { |r| model.send(selected_reasons_attr_name).include?(r.id) }
          .map { |r| r.inflate(model) }
      end

      self
    end

    def initialize(attrs)
      super
      @details = Details.new(attrs[:details]) if attrs.key?(:details)
      @reasons = attrs[:reasons].map { |rattrs| self.class.new(rattrs) } if attrs.key?(:reasons)
      @selected_reasons = attrs[:selected_reasons].map { |rattrs| self.class.new(rattrs) } if attrs.key?(:selected_reasons)
    end

    def as_json
      json = { id:, label: }
      json = json.merge(selected_reasons:) if selected_reasons.present?
      json = json.merge(details:) if details&.text.present?
      json
    end

    def reasons_selected
      if selected_reasons && selected_reasons.empty?
        key = selected_reasons_attr_name || :base
        errors.add(key, RejectionReasons.translated_error(selected_reasons_attr_name))
      end
    end

    def selected_reasons_attr_name
      :"#{id}_selected_reasons"
    end

    def valid?
      super && valid_children?
    end

    def valid_children?
      return true unless reasons || details
      return details.valid? if details

      selected_reasons.map(&:valid?).all?(true)
    end

    def deprecated?
      !!deprecated
    end

    def errors
      return super unless details || reasons

      super.merge!(details.errors) if details
      return super unless reasons

      selected_reasons.compact.map(&:errors).each { |errors| super.merge!(errors) }

      super
    end

    def label_text
      I18n.t("rejection_reasons.label_text.#{id}", default: @label)
    end
  end
end
