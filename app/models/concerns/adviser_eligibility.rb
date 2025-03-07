# frozen_string_literal: true

module AdviserEligibility
  extend ActiveSupport::Concern

  ADVISER_STATUS_CHECK_INTERVAL = 30.minutes

  included do
    enum :adviser_status, {
      unassigned: 'unassigned',
      waiting_to_be_assigned: 'waiting_to_be_assigned',
      assigned: 'assigned',
      previously_assigned: 'previously_assigned',
    }, prefix: true

    def eligible_and_unassigned_a_teaching_training_adviser?
      validations = Adviser::ApplicationFormValidations.new(self)
      validations.valid?
    end

    def eligible_to_sign_up_for_a_teaching_training_adviser?
      refresh_adviser_status

      eligible_and_unassigned_a_teaching_training_adviser?
    end

    def already_assigned_to_an_adviser?
      refresh_adviser_status

      adviser_status_assigned? || adviser_status_previously_assigned?
    end

    def waiting_to_be_assigned_to_an_adviser?
      refresh_adviser_status

      adviser_status_waiting_to_be_assigned?
    end
  end

private

  def refresh_adviser_status
    Rails.cache.fetch("adviser_status_check_#{id}", expires_in: ADVISER_STATUS_CHECK_INTERVAL) do
      Adviser::RefreshAdviserStatusWorker.perform_async(id)
      true
    end
  end
end
