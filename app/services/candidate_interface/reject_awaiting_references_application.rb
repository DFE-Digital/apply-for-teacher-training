module CandidateInterface
  class RejectAwaitingReferencesApplication
    def self.call(application_choice)
      ActiveRecord::Base.transaction do
        ApplicationStateChange.new(application_choice).reject_at_end_of_cycle!
        application_choice.update!(
          rejection_reason: 'Awaiting references when the recruitment cycle closed.',
          rejected_at: Time.zone.now,
        )
      end
    end
  end
end
