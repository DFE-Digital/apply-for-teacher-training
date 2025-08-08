# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlash::NoLongerInterestedComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
  def call
    tag.p('You will no longer receive invitations to apply for courses.')
  end
end
