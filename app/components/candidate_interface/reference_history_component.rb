module CandidateInterface
  class ReferenceHistoryComponent < ApplicationComponent
    attr_reader :reference
    delegate :application_form, to: :reference
    delegate :application_choices, to: :application_form

    def initialize(reference)
      @reference = reference
    end

    def history
      ReferenceHistory.new(reference).all_events
    end

    def formatted_title(event)
      if event.name == 'request_cancelled'
        cancelled_title(event)
      else
        I18n.t("candidate_reference_history.#{event.name}", default: event.name.humanize)
      end
    end

  private

    def cancelled_title(event)
      return I18n.t('candidate_reference_history.request_cancelled') unless application_form.ended_without_success?

      I18n.t("candidate_reference_history.#{application_unsuccessful.status}", default: event.name.humanize) if application_unsuccessful.present?
    end

    def application_unsuccessful
      application_choices.find(&:application_unsuccessful?)
    end
  end
end
