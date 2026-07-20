module SupportInterface
  class TasksController < SupportInterfaceController
    before_action :redirect_if_production

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
      when 'run_end_of_cycle_jobs'
        EndOfCycle::RunEndOfCycleJobsWorker.perform_async
        flash[:success] = 'End of cycle jobs are running - this might take awhile!'
        redirect_to support_interface_tasks_path
      when 'delete_test_applications'
        DeleteTestApplications.perform_async
        flash[:success] = 'Scheduled job to delete test applications'
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

    def redirect_if_production
      render 'errors/not_found', status: :not_found if HostingEnvironment.production?
    end
  end
end
