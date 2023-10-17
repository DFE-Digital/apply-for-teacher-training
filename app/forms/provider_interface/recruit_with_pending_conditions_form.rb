module ProviderInterface
  class RecruitWithPendingConditionsForm
    include ActiveModel::Model

    attr_accessor :actor, :application_choice, :confirmation

    validates :confirmation, presence: true
    validates :confirmation, inclusion: { in: %w[yes no] }

    def save
      ConfirmOfferWithPendingSkeConditions.new(actor:, application_choice:).save if valid? && confirmed?

      valid?
    end

    def confirmed?
      confirmation.to_s == 'yes'
    end
  end
end
