module ProviderInterface
  class ReferencesSummaryMessage < ViewComponent::Base
    attr_reader :references, :full_name

    delegate :feedback_provided, :feedback_requested, to: :references

    def initialize(references, full_name)
      @references = references
      @full_name = full_name
    end

    def message
      if feedback_provided.blank?
        "#{I18n.t('provider_interface.references.requested_message', count: feedback_requested.count)}."
      else
        "#{I18n.t('provider_interface.references.received_message', count: feedback_provided.count)}#{other_requested_reference}."
      end
    end

  private

    def other_requested_reference
      return if feedback_requested.blank?

      " #{I18n.t('provider_interface.references.requested_other_message', count: feedback_requested.count)}"
    end
  end
end
