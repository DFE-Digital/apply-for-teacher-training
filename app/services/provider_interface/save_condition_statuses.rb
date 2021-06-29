module ProviderInterface
  class SaveConditionStatuses
    include ImpersonationAuditHelper

    def initialize(actor:, application_choice:, conditions:)
      @auth = ProviderAuthorisation.new(actor: actor)
      @application_choice = application_choice
      @conditions = conditions
    end

    def save!
      auth.assert_can_make_decisions!(application_choice: application_choice, course_option: application_choice.current_course_option)

      audit(auth.actor) do
        ActiveRecord::Base.transaction do
          save_conditions_and_update_application!
        end
      end
    end

  private

    attr_reader :auth, :application_choice, :conditions

    def save_conditions_and_update_application!
      if conditions_met?
        transition_to_conditions_met!
      elsif conditions_not_met?
        transition_to_conditions_not_met!
      else
        save_conditions
      end
    end

    def conditions_met?
      conditions.all?(&:met?)
    end

    def conditions_not_met?
      conditions.any?(&:unmet?)
    end

    def transition_to_conditions_met!
      ApplicationStateChange.new(application_choice).confirm_conditions_met!
      application_choice.update!(recruited_at: Time.zone.now)
      save_conditions
      CandidateMailer.conditions_met(application_choice).deliver_later
      StateChangeNotifier.new(:recruited, application_choice).application_outcome_notification
    end

    def transition_to_conditions_not_met!
      ApplicationStateChange.new(application_choice).conditions_not_met!
      application_choice.update!(conditions_not_met_at: Time.zone.now)
      save_conditions
      CandidateMailer.conditions_not_met(application_choice).deliver_later
    end

    def save_conditions
      conditions.each do |condition|
        application_choice.offer.conditions.find(condition.id).update!(status: condition.status)
      end
    end
  end
end
