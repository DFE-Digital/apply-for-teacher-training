module EndOfCycle
  class CancelReferenceRequestsWorker < ApplicationJob
    BATCH_SIZE = 200

    def perform
      return unless run?

      BatchDelivery.new(relation:, stagger_over: 2.hours, batch_size: BATCH_SIZE).each do |batch_time, references|
        CancelReferenceRequestsSecondaryWorker.perform_at(batch_time, references.pluck(:id))
      end
    end

  private

    def relation
      requested_references = ApplicationReference.joins(application_form: :application_choices).feedback_requested
      choice_ids = requested_references.pluck('application_choices.id')
      requested_reference_choice_ids = if run_cancel_reference_requests?
                                         september_choice_ids = ApplicationChoice
                                                                .course_start_in_september(RecruitmentCycleTimetable.current_year)
                                                                .where(id: choice_ids)
                                                                .ids
                                         january_choice_ids = ApplicationChoice
                                           .course_starts_after_september(RecruitmentCycleTimetable.current_year)
                                           .where(id: choice_ids)
                                           .ids
                                         september_choice_ids - january_choice_ids
                                       elsif run_winter_cancel_reference_requests?
                                         ApplicationChoice
                                           .course_starts_after_september(RecruitmentCycleTimetable.previous_year)
                                           .where(id: choice_ids)
                                           .ids
                                       end
      requested_references.where(application_choices: { id: requested_reference_choice_ids })
    end

    def run?
      run_cancel_reference_requests? || run_winter_cancel_reference_requests?
    end

    def run_cancel_reference_requests?
      @run_cancel_reference_requests ||= EndOfCycle::JobTimetabler.new.run_cancel_reference_requests?
    end

    def run_winter_cancel_reference_requests?
      @run_winter_cancel_reference_requests ||= EndOfCycle::WinterJobTimetabler.new.run_winter_cancel_reference_requests?
    end
  end

  class CancelReferenceRequestsSecondaryWorker < ApplicationJob
    def perform(reference_ids)
      ApplicationReference.feedback_requested.where(id: reference_ids).find_each do |reference|
        CancelReferee.new.call(reference:)
      end
    end
  end
end
