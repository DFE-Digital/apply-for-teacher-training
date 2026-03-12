module ProviderInterface
  class ApplicationStatusTagComponent < ApplicationComponent
    delegate :status, to: :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
      @supplementary_statuses = application_choice.respond_to?(:supplementary_statuses) ? application_choice.supplementary_statuses : []
    end

    def text
      I18n.t!("provider_application_states.#{status}")
    end

    def colour
      case status
      when 'unsubmitted', 'cancelled', 'application_not_sent'
        # will never be visible to the provider
      when 'awaiting_provider_decision', 'inactive'
        'purple'
      when 'interviewing', 'offer_deferred'
        'yellow'
      when 'offer'
        'turquoise'
      when 'pending_conditions'
        'blue'
      when 'recruited'
        'green'
      when 'rejected', 'conditions_not_met', 'offer_withdrawn'
        'orange'
      when 'declined', 'withdrawn'
        'red'
      else
        raise "You need to define a colour for the #{status} state"
      end
    end

    def supplementary_tags
      @supplementary_statuses.each do |supplementary_status|
        yield supplementary_tag_text(supplementary_status), supplementary_tag_colour(supplementary_status)
      end
    end

  private

    def supplementary_tag_text(supplementary_status)
      I18n.t!("supplementary_application_states.#{supplementary_status}.name")
    end

    def supplementary_tag_colour(supplementary_status)
      case supplementary_status.to_s
      when 'ske_pending_conditions'
        'blue'
      else
        raise "You need to define a colour for the #{supplementary_status} supplementary state"
      end
    end

    attr_reader :application_choice
  end
end
