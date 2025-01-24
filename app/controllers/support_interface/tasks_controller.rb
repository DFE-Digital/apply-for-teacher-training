module SupportInterface
  class TasksController < SupportInterfaceController
    def index; end

    def run
      case params.fetch(:task)
      when 'generate_test_applications'
        GenerateTestApplications.perform_async
        flash[:success] = 'Scheduled job to generate test applications - this might take a while!'
        redirect_to support_interface_tasks_path
      when 'generate_next_cycle_test_applications'
        GenerateTestApplications.perform_async(true)
        flash[:success] = 'Scheduled job to generate next cycle test applications - this might take a while!'
        redirect_to support_interface_tasks_path
      when 'delete_test_applications'
        DeleteTestApplications.perform_async
        flash[:success] = 'Scheduled job to delete test applications'
        redirect_to support_interface_tasks_path
      when 'send_deferred_offer_reminder_emails'
        SendDeferredOfferReminderEmailToCandidatesWorker.perform_async
        flash[:success] = 'Scheduled job to send emails to candidates with pending offers from the previous cycle'
        redirect_to support_interface_tasks_path
      when 'cancel_applications_at_end_of_cycle'
        CancelPreviousCycleUnsubmittedApplicationsWorker.perform_async
        flash[:success] = 'Scheduled job to cancel unsubmitted applications, from the previous cycle, that reached end-of-cycle'
        redirect_to support_interface_tasks_path
      else
        render_404
      end
    end

    def create_fake_provider
      @new_provider = GenerateFakeProvider.generate_provider(
        {
          name: Faker::University.name,
          code: Faker::Alphanumeric.unique.alphanumeric(number: 3).upcase,
        },
      )
      @vendor_api_token = VendorAPIToken.create_with_random_token!(provider: @new_provider)
    end

  private

    def real_current_year
      if CycleTimetable.use_database_timetables?
        RecruitmentCycleTimetable.real_current_year
      else
        CycleTimetable.current_year
      end
    end

    def next_year
      if CycleTimetable.use_database_timetables?
        real_current_year + 1
      else
        RecruitmentCycle.next_year
      end
    end
    helper_method :current_year, :next_year
  end
end
