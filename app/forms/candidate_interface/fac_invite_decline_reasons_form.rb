module CandidateInterface
  class FacInviteDeclineReasonsForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :reasons, default: -> { [] }
    attribute :comment, :string

    validate :reasons_must_not_be_empty

    def save(invite)
      return false unless valid?

      reasons.each do |reason|
        next if reason.blank?

        if reason == 'other'
          next if comment.blank?

          invite.invite_decline_reasons.create!(
            reason: reason,
            comment: comment.strip,
          )
        else
          invite.invite_decline_reasons.create!(
            reason: reason,
            comment: nil,
          )
        end
      end
      invite.update(candidate_decision: 'declined')
    end

  private

    def reasons_must_not_be_empty
      if reasons.blank? || reasons.compact_blank.empty?
        errors.add(:reasons, :blank)
      end
    end
  end
end
