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
      @reasons ||= RejectionReasons.from_json_array(structured_rejection_reasons).selected_reasons
    end

    def nested_reasons(reason)
      reason.selected_reasons.each_with_object([]) do |nested_reason, ary|
        if nested_reason.details
          ary << "#{nested_reason.label}:" if render_label?(nested_reason.label, reason.selected_reasons)
          ary << nested_reason.details.text
        else
          ary << "#{nested_reason.label}."
        end
      end
    end

    def render_label?(label, nested_reasons)
      label != 'Other' || nested_reasons.size > 1
    end
  end
end
