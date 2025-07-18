module CandidateInterface
  class InvitesComponent < ViewComponent::Base
    attr_reader :application_form, :invites

    def initialize(application_form:, invites:)
      @application_form = application_form
      @invites = invites
    end
  end
end
