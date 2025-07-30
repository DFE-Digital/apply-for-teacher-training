module CandidateInterface
  class FacInviteResponseForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :invite
    attribute :apply_for_this_course, :string

    validates :apply_for_this_course, presence: true

    def save
      return false unless valid?

      true
    end

    def accepted_invite?
      apply_for_this_course.to_s.strip.downcase == 'yes'
    end
  end
end
