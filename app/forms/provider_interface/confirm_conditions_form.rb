module ProviderInterface
  class ConfirmConditionsForm
    include ActiveModel::Model

    attr_accessor :conditions_met
    validates :conditions_met, presence: true

    def conditions_met?
      conditions_met == 'yes'
    end
  end
end
