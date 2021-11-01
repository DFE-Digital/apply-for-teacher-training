module ProviderInterface
  class CancelInterviewWizard
    include Wizard
    include Wizard::PathHistory

    attr_accessor :cancellation_reason, :path_history, :wizard_path_history

    validates :cancellation_reason, presence: true, word_count: { maximum: 2000 }
  end
end
