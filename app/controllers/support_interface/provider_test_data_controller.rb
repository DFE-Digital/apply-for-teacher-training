module SupportInterface
  class ProviderTestDataController < SupportInterfaceController
    before_action :check_this_is_sandbox

    DEFAULT_APPLICATION_COUNT = 100
    DEFAULT_COURSES_COUNT = 1

    def create
      GenerateTestApplicationsForProvider.new(
        provider: provider,
        courses_per_application: DEFAULT_COURSES_COUNT,
        count: DEFAULT_APPLICATION_COUNT,
      ).call

      flash[:success] = 'Scheduled a job to generate test applications - this might take a while!'
      redirect_to support_interface_provider_applications_path(provider)
    end

  private

    def check_this_is_sandbox
      return if HostingEnvironment.sandbox_mode?

      render_403
    end

    def provider
      @provider ||= Provider.find(params[:provider_id])
    end
  end
end
