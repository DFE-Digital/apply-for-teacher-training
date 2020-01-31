module ProviderInterface
  class EditResponseForm
    include ActiveModel::Model

    attr_accessor :application_choice, :edit_response_type
    validates :edit_response_type, presence: true
  end
end
