module CandidateInterface
  class ApplicationsLeftMessageComponent < ApplicationComponent
    attr_reader :application_form

    delegate :submitted?,
             :number_of_slots_left,
             :unsuccessful_retry_limit,
             :in_progress_limit,
             :total_application_limit,
             to: :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def messages
      {
        application_limit_message => !submitted?,
        can_add_more_message => submitted?,
        inactive_application_message => unsuccessful_retry_limit.positive? && !show_totals?,
      }.select { |_k, v| v }.keys
    end

  private

    def application_limit_message
      show_totals? ? total_application_limit_message : in_progress_limit_message
    end

    def show_totals?
      total_application_limit == in_progress_limit
    end

    def total_application_limit_message
      t('candidate_interface.applications_left_message.total_application_limit', count: total_application_limit)
    end

    def in_progress_limit_message
      t('candidate_interface.applications_left_message.in_progress_limit', count: in_progress_limit)
    end

    def can_add_more_message
      t('candidate_interface.applications_left_message.can_add_more', count: number_of_slots_left)
    end

    def inactive_application_message
      t('candidate_interface.applications_left_message.inactive_application_message', count: unsuccessful_retry_limit)
    end
  end
end
