module ProviderInterface
  class ChangeDecisionComponent < ActionView::Component::Base
    include ViewHelper

    ChangeOption = Struct.new(:value, :label, :description)
    Choice = Struct.new(:current_state, :change_options)

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def choice
      case application_choice.status
      when 'offer'
        Choice.new(
          'This candidate has not accepted your offer yet. Would you like to withdraw your offer and reject this application?',
          [ChangeOption.new(:reject, 'Reject this application', 'The candidate will be notified')],
        )
      else
        raise RuntimeError.new("Tried to render a ChangeDecisionComponent for an ApplicationChoice in the #{application_choice.status} state")
      end
    end
  end
end
