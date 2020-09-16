module CandidateInterface
  class CancelReferenceAtEndOfCycle
    def self.call(application_reference)
      ActiveRecord::Base.transaction do
        application_reference.cancelled_at_end_of_cycle!
        RefereeMailer.reference_cancelled_email(application_reference).deliver_later
      end
    end
  end
end
