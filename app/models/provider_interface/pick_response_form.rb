module ProviderInterface
  class PickResponseForm
    include ActiveModel::Model

    VALID_CHANGE_DECISIONS = %w[edit_course edit_course_option edit_provider].freeze
    VALID_DECISIONS = (%w[new_offer new_reject] + VALID_CHANGE_DECISIONS).freeze

    attr_accessor :decision
    validates :decision, inclusion: { in: VALID_DECISIONS }

    def decision_is_change?
      VALID_CHANGE_DECISIONS.include?(decision)
    end
  end
end
