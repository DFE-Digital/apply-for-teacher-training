module ProviderInterface
  class PickResponseForm
    include ActiveModel::Model

    VALID_CHANGE_DECISIONS = %w[edit_course edit_course_option edit_provider].freeze
    VALID_DECISIONS = (%w[new_offer new_reject] + VALID_CHANGE_DECISIONS).freeze

    attr_accessor :decision
    validates :decision, inclusion: { in: VALID_DECISIONS }

    def redirect_attrs
      attrs = {}

      if decision_is_change?
        attrs[:controller] = 'offer_changes'
        attrs[:action] = 'edit_offer'
        attrs[:step] = case decision
                       when 'edit_provider' then 'provider'
                       when 'edit_course' then 'course'
                       when 'edit_course_option' then 'course_option'
                       end
      else
        attrs[:controller] = 'decisions'
        attrs[:action] = decision
      end

      attrs
    end

    def decision_is_change?
      VALID_CHANGE_DECISIONS.include?(decision)
    end
  end
end
