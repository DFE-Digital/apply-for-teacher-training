module SupportInterface
  class ProvidersController < SupportInterfaceController
    include ActionController::Live
    include StreamableDataExport

    PAGY_PER_PAGE = 30

    def index
      authorize nil, :show?, policy_class: SupportInterface::ProviderPolicy

      @filter = SupportInterface::ProvidersFilter.new(params:)

      providers_scope = @filter.filter_records(
        Provider
          .includes(:courses, :provider_agreements, :provider_users)
          .order(:name),
      )

      @pagy, @providers = pagy(providers_scope, limit: PAGY_PER_PAGE)
    end

    def show
      @provider = Provider.find(params.expect(:provider_id))

      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy

      @provider_agreement = ProviderAgreement.data_sharing_agreements.for_provider(@provider).last
    end

    def courses
      @provider = Provider.includes(courses: [:accredited_provider]).find(params.expect(:provider_id))

      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy

      courses = @provider.courses.includes(accredited_provider: [:provider_agreements]).order(:name).group_by(&:recruitment_cycle_year)
      years = RecruitmentCycleTimetable.years_visible_in_support.reverse.to_h { |year| [year, []] } # rubocop:disable Rails/IndexWith

      @courses_by_year = years.merge(courses)
    end

    def ratified_courses
      @provider = Provider.includes(courses: [:accredited_provider]).find(params.expect(:provider_id))

      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy

      @ratified_courses = @provider.accredited_courses.includes(:provider, accredited_provider: [:provider_agreements]).order(:name).group_by(&:recruitment_cycle_year)
    end

    def vacancies
      @provider = Provider.find(params.expect(:provider_id))
      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy

      @course_options = @provider.course_options.includes(:course, :site)
    end

    def users
      authorize nil, :show?, policy_class: SupportInterface::ProviderUserPolicy

      @provider = Provider.includes(provider_users: [provider_permissions: [:provider]]).find(params.expect(:provider_id))
      @relationship_diagram = SupportInterface::ProviderRelationshipsDiagram.new(provider: @provider)
    end

    def relationships
      @provider = Provider.find(params.expect(:provider_id))

      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy

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
      @provider = Provider.find(params.expect(:provider_id))

      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy

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

    def applications
      authorize nil, :show?, policy_class: SupportInterface::CandidatePolicy

      @provider = Provider.find(params.expect(:provider_id))
      @filter = SupportInterface::ApplicationsFilter.new(
        params: params.merge(provider_id: @provider.id),
      )
      @pagy, @application_forms = @filter.filter_records(ApplicationForm.all)
    end

    def sites
      @provider = Provider.includes(:courses, :sites).find(params.expect(:provider_id))

      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy
    end

    def history
      @provider = Provider.find(params.expect(:provider_id))

      authorize @provider, :show?, policy_class: SupportInterface::ProviderPolicy
    end

    def courses_as_csv
      provider = Provider.find(params.expect(:provider_id))

      authorize provider, :show?, policy_class: SupportInterface::ProviderPolicy

      stream_csv(
        data: SupportInterface::ProviderCoursesCSVExport.new(provider:).rows,
        filename: "#{provider.name_and_code.parameterize}-courses-#{current_timetable.recruitment_cycle_year}.csv",
      )
    end

  private

    def relationships_params
      params
        .expect(support_interface_provider_relationships_form: [relationships: {}])
    end

    def update_provider(success_message)
      @provider = Provider.find(params.expect(:provider_id))

      yield @provider

      flash[:success] = success_message
      redirect_to support_interface_provider_courses_path(@provider)
    end
  end
end
