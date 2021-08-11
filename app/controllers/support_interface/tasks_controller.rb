module SupportInterface
  class TasksController < SupportInterfaceController
    def index; end

    def run
      case params.fetch(:task)
      when 'generate_test_applications'
        GenerateTestApplications.perform_async
        flash[:success] = 'Scheduled job to generate test applications - this might take a while!'
        redirect_to support_interface_tasks_path
      when 'sync_providers'
        TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async
        flash[:success] = 'Scheduled job to sync providers'
        redirect_to support_interface_tasks_path
      when 'recalculate_dates'
        RecalculateDates.perform_async
        flash[:success] = 'Scheduled job to recalculate dates'
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
        CancelUnsubmittedApplicationsWorker.perform_async
        flash[:success] = 'Scheduled job to cancel unsubmitted applications that reached end-of-cycle'
        redirect_to support_interface_tasks_path
      when 'open_all_courses_on_apply'
        OpenAllCoursesOnApplyWorker.perform_async
        flash[:success] = 'Scheduled job to make all courses open on Apply'
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
  end
end
