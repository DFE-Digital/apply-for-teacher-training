module ProviderInterface
  class RecruitWithPendingConditionsForm
    include ActiveModel::Model

    attr_accessor :application_choice, :confirmation

    validates :confirmation, presence: true
    validates :confirmation, inclusion: { in: %w[yes no] }

    def save
      return false unless valid?

      # TODO: 
      true
    end
  end
end
