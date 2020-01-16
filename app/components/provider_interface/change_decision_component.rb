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
          'You have made this candidate an offer, but they have not accepted it yet.',
          [ChangeOption.new(:reject, 'Change offer to rejection', 'Use this to rescind the offer, for example when a course is oversubscribed')],
        )
      else
        raise RuntimeError.new("Tried to render a ChangeDecisionComponent for an ApplicationChoice in the #{application_choice.status} state")
      end
    end
  end
end
