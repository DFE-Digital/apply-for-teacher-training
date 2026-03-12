module SupportInterface
  class ApplicationStatusTagComponent < ApplicationComponent
    def initialize(application_choice:)
      @status = application_choice.status
      @supplementary_statuses =
        application_choice.respond_to?(:supplementary_statuses) ? application_choice.supplementary_statuses : []
    end

    def text
      I18n.t!("application_states.#{@status}.name")
    end

    def colour
      case @status.to_s
      when 'unsubmitted'
        'grey'
      when 'awaiting_provider_decision', 'interviewing', 'offer_deferred', 'inactive'
        'yellow'
      when 'offer'
        'turquoise'
      when 'pending_conditions'
        'blue'
      when 'recruited'
        'green'
      when 'conditions_not_met', 'declined', 'rejected', 'offer_withdrawn', 'withdrawn', 'cancelled', 'application_not_sent'
        'red'
      else
        raise "You need to define a colour for the #{@status} state"
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
  end
end
