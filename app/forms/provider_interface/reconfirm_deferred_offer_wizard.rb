module ProviderInterface
  class ReconfirmDeferredOfferWizard
    include ActiveModel::Model

    STEPS = %w[start conditions check].freeze

    attr_accessor :current_step, :application_choice_id
    attr_accessor :conditions_status, :course_option_id
    attr_writer :state_store

    validates :application_choice_id, :current_step, presence: true

    validate :validate_step,
             :validate_application_choice,
             :is_course_option_still_available

    validates :conditions_status, presence: true, on: %i[conditions check]
    validates :course_option_id, presence: true, on: %i[check]

    def valid?
      super(current_step&.to_sym)
    end

    def initialize(state_store, attrs = {})
      @state_store = state_store

      super(last_saved_state.deep_merge(attrs))
    end

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
      @course_option_in_new_cycle ||= application_choice&.current_course_option&.in_next_cycle
    end

    def is_course_option_still_available
      if current_step != 'start'
        errors.add(:course_option_in_new_cycle, "No matching course option in #{RecruitmentCycle.current_year}") unless course_option_in_new_cycle
        errors.add(:course_option_in_new_cycle, 'New course option is not open on Apply') unless course_option_in_new_cycle&.course&.open_on_apply == true
      end
    end

    def applicable?
      course_option_in_new_cycle&.course&.open_on_apply
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

    def save_state!
      @state_store.write(state)
    end

    def clear_state!
      @state_store.delete
    end

  private

    def state
      as_json(except: %w[state_store errors validation_context application_choice course_option_in_new_cycle current_step]).to_json
    end

    def last_saved_state
      state = @state_store.read

      if state
        JSON.parse(state)
      else
        {}
      end
    end

    def deferred_offer_data
      @_deferred_offer_data || {}
    end

    def validate_step
      errors.add(:current_step, 'Specified step is not valid') unless STEPS.include?(current_step)
    end
  end
end
