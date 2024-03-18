module ProviderInterface
  class ReconfirmDeferredOfferWizard
    include Wizard

    STEPS = %w[new conditions check].freeze

    attr_accessor :application_choice_id, :conditions_status, :course_option_id

    validates :application_choice_id, :current_step, presence: true

    validate :validate_step, :validate_application_choice, :course_option_still_available

    validates :conditions_status, presence: true, on: %i[conditions check]
    validates :course_option_id, presence: true, on: %i[check]

    def application_choice
      @application_choice ||= ApplicationChoice.find(application_choice_id)
    end

    def validate_application_choice
      if application_choice
        unless application_choice.status == 'offer_deferred'
          errors.add(:application_choice_id, 'Application status is not a deferred offer')
        end
        unless application_choice.recruitment_cycle == RecruitmentCycle.previous_year
          errors.add(:application_choice_id, "Deferred offer is not from #{RecruitmentCycle.previous_year}")
        end
      else
        errors.add(:application_choice_id, 'No application choice has been supplied')
      end
    end

    def course_option_in_new_cycle
      @course_option_in_new_cycle ||= application_choice&.current_course_option&.in_next_cycle
    end

    def course_option_still_available
      if current_step != 'new' && !course_option_in_new_cycle
        errors.add(:course_option_in_new_cycle, "No matching course option in #{RecruitmentCycle.current_year}")
      end
    end

    def applicable?
      course_option_in_new_cycle&.course.present?
    end

    def conditions_met?
      conditions_status.present? && conditions_status == 'met'
    end

    def course_option
      CourseOption.find(course_option_id) if course_option_id.present?
    end

    def modified_application_choice
      return unless application_choice

      modified_application_choice = application_choice.clone
      modified_application_choice.status = if conditions_status.present?
                                             if conditions_met?
                                               modified_application_choice.offer.conditions.each { |condition| condition.status = 'met' }
                                               'recruited'
                                             else
                                               modified_application_choice.offer.conditions.each { |condition| condition.status = 'pending' }
                                               'pending_conditions'
                                             end
                                           else
                                             application_choice.status_before_deferral
                                           end
      modified_application_choice
    end

    def next_step
      if current_step == 'new'
        :conditions
      elsif current_step == 'conditions'
        :check
      elsif current_step == 'check'
        nil
      else
        :new
      end
    end

    def previous_step
      if current_step == 'new'
        nil
      elsif current_step == 'conditions'
        :new
      elsif current_step == 'check'
        :conditions
      end
    end

  private

    def state_excluded_attributes
      %w[state_store errors validation_context application_choice course_option_in_new_cycle current_step]
    end

    def deferred_offer_data
      @_deferred_offer_data || {}
    end

    def validate_step
      errors.add(:current_step, 'Specified step is not valid') unless STEPS.include?(current_step)
    end
  end
end
