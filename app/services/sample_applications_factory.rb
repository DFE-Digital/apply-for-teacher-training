class SampleApplicationsFactory
  class << self
    def create_application(states:, courses_to_apply_to:, recruitment_cycle_year: CycleTimetable.current_year, apply_again: false, carry_over: false, course_full: false, candidate: nil)
      if states.blank?
        raise ArgumentError, '`states` must be an array of at least one state'
      end

      if Array(courses_to_apply_to).count < states.count
        raise ArgumentError, '`courses_to_apply_to` must have at least as many courses as the number of states requested'
      end

      if carry_over && apply_again
        raise ArgumentError, 'Cannot set both carry_over and apply_again to true'
      end

      form_options = {
        recruitment_cycle_year:,
        full_work_history: true,
        references_count: 0,
      }

      form_options[:candidate] = candidate if candidate

      form = Satisfactory.root.add(:application_form, **form_options).which_is(:completed)
      form = form.which_is(:apply_again) if apply_again
      form = form.which_is(:carry_over) if carry_over

      states.each do |state|
        form = form
          .with(2, :application_references)
          .which_are(feedback_status_for(state))
          .and_same(:application_form)
          .with(:application_choice)
          .which_is(application_choice_state_for(state))
          .with(:course_option, course: courses_to_apply_to.sample)
          .return_to(:application_form)
      end

      form_record = form.create[:application_form].first

      form_record.application_choices.tap do |choices|
        if ApplicationFormStateInferrer.new(form_record).post_submission?
          form_record.update(submitted_at: choices.map(&:created_at).max + 1.second)
        end
      end
    end

  private

    def feedback_status_for(state)
      case state
      when :accepted
        :feedback_requested
      when :recruited
        :feedback_provided
      else
        :not_requested_yet
      end
    end

    def application_choice_state_for(state)
      case state
      when :offer
        :offered
      when :interviewing
        if CycleTimetable.between_reject_by_default_and_find_reopens?
          :awaiting_provider_decision
        else
          state
        end
      else
        state
      end
    end
  end
end
