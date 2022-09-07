module ProviderInterface
  class SaveConditionStatuses
    include ImpersonationAuditHelper

    def initialize(actor:, application_choice:, statuses_form_object:)
      @auth = ProviderAuthorisation.new(actor:)
      @application_choice = application_choice
      @statuses_form_object = statuses_form_object
      @previously_met_conditions = []
      @pending_conditions = []
      @met_conditions = []
    end

    def save!
      auth.assert_can_make_decisions!(application_choice:, course_option: application_choice.current_course_option)

      audit(auth.actor) do
        ActiveRecord::Base.transaction do
          save_conditions_and_update_application!
        end
        send_success_notifications
      end
    end

  private

    attr_reader :auth, :application_choice, :statuses_form_object

    def save_conditions_and_update_application!
      if statuses_form_object.all_conditions_met?
        transition_to_conditions_met!
      elsif statuses_form_object.any_condition_not_met?
        transition_to_conditions_not_met!
      else
        save_conditions
      end
    end

    def transition_to_conditions_met!
      ApplicationStateChange.new(application_choice).confirm_conditions_met!
      application_choice.update!(recruited_at: Time.zone.now)
      save_conditions
    end

    def transition_to_conditions_not_met!
      ApplicationStateChange.new(application_choice).conditions_not_met!
      application_choice.update!(conditions_not_met_at: Time.zone.now)
      save_conditions
    end

    def save_conditions
      statuses_form_object.conditions.each do |condition|
        condition_to_update = application_choice.offer.conditions.find(condition.id)
        detect_changed_statuses(condition_to_update, condition.status)
        condition_to_update.update!(status: condition.status)
      end
    end

    def detect_changed_statuses(condition, new_status)
      if new_status == 'pending' && condition.met?
        @previously_met_conditions << condition
      elsif new_status == 'pending' && condition.pending?
        @pending_conditions << condition
      elsif new_status == 'met' && condition.pending?
        @met_conditions << condition
      end
    end

    def conditions_statuses_changed?
      @previously_met_conditions.any? || @pending_conditions.any? || @met_conditions.any?
    end

    def send_success_notifications
      if application_choice.recruited?
        CandidateMailer.conditions_met(application_choice).deliver_later
      elsif application_choice.conditions_not_met?
        CandidateMailer.conditions_not_met(application_choice).deliver_later
      elsif conditions_statuses_changed?
        CandidateMailer.conditions_statuses_changed(
          application_choice,
          @met_conditions,
          @pending_conditions,
          @previously_met_conditions,
        ).deliver_later
      end
    end
  end
end
