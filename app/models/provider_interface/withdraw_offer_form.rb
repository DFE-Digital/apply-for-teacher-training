module ProviderInterface
  class WithdrawOfferForm
    include ActiveModel::Model

    attr_accessor :application_choice, :comment
    validates :comment, presence: true
  end
end
