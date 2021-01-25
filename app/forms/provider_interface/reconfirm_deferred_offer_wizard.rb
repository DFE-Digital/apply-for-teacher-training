module ProviderInterface
  class ReconfirmDeferredOfferWizard
    include ActiveModel::Model
    include Wizard

    STEPS = %w[start conditions check].freeze

    attr_accessor :application_choice_id, :conditions_status, :course_option_id
    attr_writer :state_store

    validates :application_choice_id, :current_step, presence: true

    validate :validate_step,
             :validate_application_choice,
             :is_course_option_still_available

    validates :conditions_status, presence: true, on: %i[conditions check]
    validates :course_option_id, presence: true, on: %i[check]

    def application_choice
      @application_choice ||= ApplicationChoice.find(application_choice_id)
    end

    def validate_application_choice
      if application_choice
        errors.add(:application_choice_id, 'Application status is not a deferred offer') \
          unless application_choice.status == 'offer_deferred'
        errors.add(:application_choice_id, "Deferred offer is not from #{RecruitmentCycle.previous_year}") \
          unless application_choice.recruitment_cycle == RecruitmentCycle.previous_year
      else
        errors.add(:application_choice_id, 'No application choice has been supplied')
      end
    end

    def course_option_in_new_cycle
      @course_option_in_new_cycle ||= application_choice&.offered_option&.in_next_cycle
    end

    def is_course_option_still_available
      if current_step != 'start'
        errors.add(:course_option_in_new_cycle, "No matching course option in #{RecruitmentCycle.current_year}") unless course_option_in_new_cycle
        errors.add(:course_option_in_new_cycle, 'New course option is not open on Apply') unless course_option_in_new_cycle&.course&.open_on_apply == true
      end
    end

    def applicable?
      course_option_in_new_cycle && course_option_in_new_cycle.course.open_on_apply
    end

    def conditions_met?
      conditions_status.present? && conditions_status == 'met'
    end

    def course_option
      CourseOption.find(course_option_id) if course_option_id.present?
    end

    def modified_application_choice
      return unless application_choice

      clone = application_choice.dup
      clone.id = application_choice.id

      clone.status = if conditions_status.present?
                       conditions_met? ? 'recruited' : 'pending_conditions'
                     else
                       clone.status_before_deferral
                     end
      clone
    end

    def next_step
      if current_step == 'start'
        :conditions
      elsif current_step == 'conditions'
        :check
      elsif current_step == 'check'
        nil
      else
        :start
      end
    end

    def previous_step
      if current_step == 'start'
        nil
      elsif current_step == 'conditions'
        :start
      elsif current_step == 'check'
        :conditions
      end
    end

  private

    def params_to_exclude_from_saved_state
      super + %w[application_choice course_option_in_new_cycle]
    end

    def deferred_offer_data
      @_deferred_offer_data || {}
    end

    def validate_step
      errors.add(:current_step, 'Specified step is not valid') unless STEPS.include?(current_step)
    end
  end
end
