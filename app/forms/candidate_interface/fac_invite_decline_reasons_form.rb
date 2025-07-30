module CandidateInterface
  class FacInviteDeclineReasonsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :reasons, default: -> { [] }
    attribute :comment, :string

    validate :reasons_must_not_be_empty

    def save(invite)
      return false unless valid?

      invite_decline_reasons_attributes = reasons.compact_blank.map do |reason|
        if reason == 'other'
          { reason: reason, comment: comment.strip }
        else
          { reason: reason, comment: nil }
        end
      end

      invite.assign_attributes(
        invite_decline_reasons_attributes: invite_decline_reasons_attributes,
        candidate_decision: 'declined',
      )

      invite.save!
    end

  private

    def reasons_must_not_be_empty
      if reasons.blank? || reasons.compact_blank.empty?
        errors.add(:reasons, :blank)
      end
    end
  end
end
