class RejectionReasons
  class Reason
    include ActiveModel::Model

    TRANSLATION_KEY_PREFIX = 'activemodel.errors.models.provider_interface/rejections_wizard.attributes'.freeze

    attr_accessor :id, :details, :label, :reasons, :selected_reasons

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
      super(attrs)
      @details = Details.new(attrs[:details]) if attrs.key?(:details)
      @reasons = attrs[:reasons].map { |rattrs| self.class.new(rattrs) } if attrs.key?(:reasons)
    end

    def reasons_selected
      key = (selected_reasons_attr_name || :base)
      errors.add(key, I18n.t("#{TRANSLATION_KEY_PREFIX}.#{selected_reasons_attr_name}")) if selected_reasons && selected_reasons.empty?
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

    def errors
      return super unless details || reasons

      super.merge!(details.errors) if details
      return super unless reasons

      selected_reasons.compact.map(&:errors).each { |errors| super.merge!(errors) }

      super
    end
  end
end
