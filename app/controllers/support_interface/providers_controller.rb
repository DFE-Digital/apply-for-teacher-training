module SupportInterface
  class ProvidersController < SupportInterfaceController
    include ActionController::Live
    include StreamableDataExport

    PAGY_PER_PAGE = 30

    def index
      @filter = SupportInterface::ProvidersFilter.new(params:)

      providers_scope = @filter.filter_records(
        Provider
          .includes(:courses, :provider_agreements, :provider_users)
          .order(:name),
      )

      @pagy, @providers = pagy(providers_scope, limit: PAGY_PER_PAGE)
    end

    def show
      @provider = Provider.find(params[:provider_id])
      @provider_agreement = ProviderAgreement.data_sharing_agreements.for_provider(@provider).last
    end

    def courses
      @provider = Provider.includes(courses: [:accredited_provider]).find(params[:provider_id])

      courses = @provider.courses.includes(accredited_provider: [:provider_agreements]).order(:name).group_by(&:recruitment_cycle_year)
      years = RecruitmentCycleTimetable.years_visible_in_support.each_with_object({}) { |year, hash| hash[year] = [] } # rubocop:disable Rails/IndexWith

      @courses_by_year = years.merge(courses)
    end

    def ratified_courses
      @provider = Provider.includes(courses: [:accredited_provider]).find(params[:provider_id])
      @ratified_courses = @provider.accredited_courses.includes(:provider, accredited_provider: [:provider_agreements]).order(:name).group_by(&:recruitment_cycle_year)
    end

    def vacancies
      @provider = Provider.find(params[:provider_id])
      @course_options = @provider.course_options.includes(:course, :site)
    end

    def users
      @provider = Provider.includes(provider_users: [provider_permissions: [:provider]]).find(params[:provider_id])
      @relationship_diagram = SupportInterface::ProviderRelationshipsDiagram.new(provider: @provider)
    end

    def relationships
      @provider = Provider.find(params[:provider_id])
      relationships = ProviderRelationshipPermissions.where(
        training_provider: @provider,
      ).or(
        ProviderRelationshipPermissions.where(
          ratifying_provider: @provider,
        ),
      )

      if relationships.empty?
        render 'no_relationships'
      else
        @relationships_form = SupportInterface::ProviderRelationshipsForm.from_models(relationships)
      end
    end

    def update_relationships
      @provider = Provider.find(params[:provider_id])
      @relationships_form = SupportInterface::ProviderRelationshipsForm.from_params(
        relationships_params[:relationships],
      )

      if @relationships_form.valid?
        @relationships_form.save!
        flash[:success] = 'Relationships updated'
        redirect_to support_interface_provider_relationships_path
      else
        render :relationships
      end
    end

    def relationships_params
      params
        .expect(support_interface_provider_relationships_form: [relationships: {}])
    end

    def applications
      @provider = Provider.find(params[:provider_id])
      @filter = SupportInterface::ApplicationsFilter.new(
        params: params.merge(provider_id: @provider.id),
      )
      @pagy, @application_forms = @filter.filter_records(ApplicationForm.all)
    end

    def sites
      @provider = Provider.includes(:courses, :sites).find(params[:provider_id])
    end

    def history
      @provider = Provider.find(params[:provider_id])
    end

    def courses_as_csv
      provider = Provider.find(params[:provider_id])

      stream_csv(
        data: SupportInterface::ProviderCoursesCSVExport.new(provider:).rows,
        filename: "#{provider.name_and_code.parameterize}-courses-#{RecruitmentCycle.current_year}.csv",
      )
    end

  private

    def update_provider(success_message)
      @provider = Provider.find(params[:provider_id])

      yield @provider

      flash[:success] = success_message
      redirect_to support_interface_provider_courses_path(@provider)
    end
  end
end
