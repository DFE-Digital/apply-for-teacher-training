class SampleApplicationsFactory
  class << self
    # FIXME: `course_full` and `incomplete_references` are just here to maintain the same interface as `TestApplications`
    def create_application(states:, courses_to_apply_to:, recruitment_cycle_year: CycleTimetable.current_year, apply_again: false, carry_over: false, course_full: false, candidate: nil, incomplete_references: nil) # rubocop:disable Lint/UnusedMethodArgument
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
      form_options[:references_completed] = true if states.include?(:unsubmitted_with_completed_references)
      form_options[:submitted_at] = nil if states.uniq.difference(%i[unsubmitted unsubmitted_with_completed_references]).blank?

      form = Satisfactory.root.add(:application_form, **form_options).which_is(:completed).which_is(:with_bachelor_degree)
      form = form.which_is(:apply_again) if apply_again
      form = form.which_is(:carry_over) if carry_over

      form = form
        .with(2, :application_references)
        .which_are(feedback_status_for(states))
        .return_to(:application_form)

      course_list = []
      states.each do |state|
        course = (courses_to_apply_to - course_list).sample
        course_list.push(course)

        form = form
          .with(:application_choice, course_option: course.course_options.first)
          .which_is(application_choice_state_for(state))
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

    def feedback_status_for(states)
      if states.include?(:recruited)
        :feedback_provided
      elsif states.include?(:accepted)
        :feedback_requested
      else
        :not_requested_yet
      end
    end

    def application_choice_state_for(state)
      if state == :offer
        :offered
      elsif state == :interviewing && CycleTimetable.between_reject_by_default_and_find_reopens?
        :awaiting_provider_decision
      elsif state == :unsubmitted_with_completed_references
        :unsubmitted
      else
        state
      end
    end
  end
end
