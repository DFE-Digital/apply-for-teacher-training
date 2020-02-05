module ProviderInterface
  class EditResponseForm
    include ActiveModel::Model

    attr_accessor :application_choice, :edit_response_type
    validates :edit_response_type, presence: true
    validates :edit_response_type, inclusion: { in: %w(withdraw_offer), message: '%{value} is not a valid option' }
  end
end
