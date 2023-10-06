module ProviderInterface
  class RecruitWithPendingConditionsForm
    include ActiveModel::Model

    attr_accessor :actor, :application_choice, :confirmation

    validates :confirmation, presence: true
    validates :confirmation, inclusion: { in: %w[yes no] }

    def save
      return false unless valid?

      # TODO: Work out whether we really need the radio buttons here and hence
      # whether we even need the `confirmation` attribute here.
      if confirmed?
        ConfirmOfferConditions.new(actor:, application_choice:, updated_conditions: false).save
      end
    end

  private

    def confirmed?
      confirmation.to_s == 'yes'
    end
  end
end
