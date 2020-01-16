module SupportInterface
  class ProvidersController < SupportInterfaceController
    def index
      @providers = Provider.includes(:sites, :courses).order(:name)
    end

    def show
      @provider = Provider.includes(:courses, :sites).find(params[:provider_id])
      @provider_agreement = ProviderAgreement.data_sharing_agreements.for_provider(@provider).last
    end

    def open_all_courses
      update_provider('Successfully updated all courses') { |provider| provider.courses.update_all(open_on_apply: true) }
    end

    def enable_course_syncing
      update_provider('Successfully updated provider') { |provider| provider.update!(sync_courses: true) }
    end

  private

    def update_provider(success_message)
      @provider = Provider.find(params[:provider_id])

      yield @provider

      flash[:success] = success_message
      redirect_to support_interface_provider_path(@provider)
    end
  end
end
