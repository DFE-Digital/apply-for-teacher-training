# Presenter for serialized RejectionReasons data.
class RejectionReasons
  class RejectionReasonsPresenter < SimpleDelegator
    def rejection_reasons
      return {} unless structured_rejection_reasons&.any?

      reasons.each_with_object({}) do |reason, hash|
        hash[reason.label] = if reason.details
                               [reason.details.text]
                             elsif reason.selected_reasons
                               nested_reasons(reason)
                             else
                               [I18n.t("rejection_reasons.#{reason.id}.description")] # Course full
                             end
      end
    end

    def reasons
      @reasons ||= RejectionReasons.new(structured_rejection_reasons).selected_reasons
    end

    def nested_reasons(reason)
      reason.selected_reasons.each_with_object([]) do |nested_reason, ary|
        ary << formatted_label(nested_reason)
        ary << nested_reason.details.text if nested_reason.details
      end
    end

    def formatted_label(reason)
      return "#{reason.label}:" if reason.details

      "#{reason.label}."
    end
  end
end
