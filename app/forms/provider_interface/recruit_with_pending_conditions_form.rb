module ProviderInterface
  class RecruitWithPendingConditionsForm
    include ActiveModel::Model

    attr_accessor :actor, :application_choice, :confirmation

    validates :confirmation, presence: true
    validates :confirmation, inclusion: { in: %w[yes no] }

    def save
      return false unless valid?

      if confirmed?
        ConfirmOfferWithPendingSkeConditions.new(actor:, application_choice:).save
      end
    end

  private

    def confirmed?
      confirmation.to_s == 'yes'
    end
  end
end
