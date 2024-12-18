module CandidateInterface
  class CourseChoicesSummaryCardActionComponent < ViewComponent::Base
    attr_reader :action, :application_choice

    def initialize(action:, application_choice:)
      @action = action
      @application_choice = application_choice
    end

    def withdrawal_path
      if FeatureFlag.active? :new_candidate_withdrawal_reasons
        candidate_interface_withdrawal_reasons_level_one_reason_start_path(application_choice.id)
      else
        candidate_interface_withdraw_path(application_choice.id)
      end
    end
  end
end
