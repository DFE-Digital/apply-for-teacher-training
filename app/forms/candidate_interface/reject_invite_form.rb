module CandidateInterface
  class RejectInviteForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :dismiss_reason
    attribute :dismiss_text
    attribute :invite

    validates :dismiss_reason, presence: true

    def save
      invite.assign_attributes(
        dismiss_reason:,
        dismiss_text:,
        candidate_invite_status: 'dismissed',
      )

      if valid?
        invite.save
      else
        false
      end
    end

    def reason_options
      option = Struct.new(:id, :name, :other_reason)

      reasons = [
        'Not interested in the course',
        'Not interested in the training location',
        'I am interested in salaried courses',
        'Other',
      ]

      reasons.map do |reason|
        option.new(
          id: reason,
          name: reason,
        )
      end
    end
  end
end
