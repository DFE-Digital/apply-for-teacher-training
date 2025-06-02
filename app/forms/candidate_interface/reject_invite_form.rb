module CandidateInterface
  class RejectInviteForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :rejection_reason
    attribute :invite

    validates :rejection_reason, presence: true

    def save
      invite.assign_attributes(
        rejection_reason:,
        candidate_invite_status: 'rejected',
      )

      if valid?
        invite.save
      else
        false
      end
    end
  end
end
