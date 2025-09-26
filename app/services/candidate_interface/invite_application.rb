module CandidateInterface
  class InviteApplication
    attr_reader :application_form, :application_choice

    def initialize(application_choice:, invite: nil)
      @application_form = application_choice.application_form
      @application_choice = application_choice
      @invite = invite
    end

    def self.accepted!(application_choice:)
      new(application_choice:).accepted!
    end

    def accepted!
      clean_up_disconnected_invites

      invite = application_form.published_invites.find_by(
        course_id: application_choice.current_course.id,
        application_choice_id: nil,
      )

      if invite.present? && application_choice.persisted?
        invite.application_choice_id = application_choice.id
        invite.candidate_decision = calculate_candidate_decision(invite)
        invite.save!
      end
    end

    def self.accept_and_link_to_choice!(application_choice:, invite:)
      new(application_choice:, invite:).accept_and_link_to_choice!
    end

    def accept_and_link_to_choice!
      @invite.application_choice_id = application_choice.id
      @invite.candidate_decision = calculate_candidate_decision(@invite)
      @invite.save!
    end

    def self.unlink_invites_from_choice(application_choice:)
      new(application_choice:).unlink_invites_from_choice
    end

    def unlink_invites_from_choice
      ActiveRecord::Base.transaction do
        application_choice.published_invites.each do |invite|
          invite.application_choice_id = nil
          invite.candidate_decision = calculate_candidate_decision(invite)
          invite.save!
        end
      end
    end

    def calculate_candidate_decision(invite)
      if invite.application_choice_id.nil? && invite.invite_decline_reasons.any?
        'declined'
      elsif invite.application_choice_id.nil?
        'not_responded'
      elsif invite.application_choice.present?
        'accepted'
      end
    end

  private

    def clean_up_disconnected_invites
      # When a candidate creates a draft choice for invited course and changes course to a non invited course
      # We then need to remove the link between the choice and the invite
      if application_choice.current_course == application_choice.original_course

        ActiveRecord::Base.transaction do
          invites = application_choice.published_invites.where.not(
            course_id: application_choice.current_course.id,
          )

          invites.each do |invite|
            invite.application_choice_id = nil
            invite.candidate_decision = calculate_candidate_decision(invite)
            invite.save!
          end
        end
      end
    end
  end
end
