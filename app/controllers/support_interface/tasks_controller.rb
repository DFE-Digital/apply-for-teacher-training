module SupportInterface
  class TasksController < SupportInterfaceController
    def index; end

    def confirm
      case params.fetch(:task)
      when 'delete_test_applications'
        render :confirm_delete_test_applications
      else
        render_404
      end
    end

    def run
      case params.fetch(:task)
      when 'generate_test_applications'
        GenerateTestApplications.perform_async
        flash[:success] = 'Scheduled job to generate test applications - this might take a while!'
        redirect_to support_interface_tasks_path
      when 'sync_providers'
        SyncAllFromFind.perform_async
        flash[:success] = 'Scheduled job to sync providers - this might take a while!'
        redirect_to support_interface_tasks_path
      when 'create_vendor_providers'
        GenerateVendorProviders.call
        flash[:success] = 'Created test providers for vendors'
        redirect_to support_interface_tasks_path
      when 'recalculate_dates'
        RecalculateDates.perform_async
        flash[:success] = 'Scheduled job to recalculate dates'
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
          name: Faker::Educator.unique.university,
          code: Faker::Alphanumeric.unique.alphanumeric(number: 3).upcase,
        },
      )
      @vendor_api_token = VendorAPIToken.create_with_random_token!(provider: @new_provider)
    end
  end
end
