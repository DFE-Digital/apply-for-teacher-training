module ProviderInterface
  class WithdrawOfferForm
    include ActiveModel::Model

    attr_accessor :application_choice, :reason
    validates :reason, presence: true
  end
end
