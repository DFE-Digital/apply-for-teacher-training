module CandidateInterface
  class FacInviteResponseForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    attr_reader :application_choice

    attribute :application_form
    attribute :invite
    attribute :apply_for_this_course, :string

    validates :apply_for_this_course, presence: true

    def save
      false if invalid?
    end

    def accepted_invite?
      apply_for_this_course.to_s.strip.downcase == 'yes'
    end
  end
end
