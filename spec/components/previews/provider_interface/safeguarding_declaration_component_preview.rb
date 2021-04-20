module ProviderInterface
  class SafeguardingDeclarationComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def can_view__with_safeguarding_issues_never_asked
      find_user_and_course safeguarding_access: true
      build_application_choice :with_safeguarding_issues_never_asked
      render_component
    end

    def can_view__with_no_safeguarding_issues
      find_user_and_course safeguarding_access: true
      build_application_choice :minimum_info
      render_component
    end

    def can_view__with_safeguarding_information
      find_user_and_course safeguarding_access: true
      build_application_choice :with_safeguarding_issues_disclosed
      render_component
    end

    def as_training_provider_user
      find_user_and_course safeguarding_access: false, org_affiliation: :training_provider
      build_application_choice :with_safeguarding_issues_disclosed
      render_component
    end

    def as_ratifying_provider_user
      find_user_and_course safeguarding_access: false, org_affiliation: :ratifying_provider
      build_application_choice :with_safeguarding_issues_disclosed
      render_component
    end

  private

    def find_user_and_course(safeguarding_access: false, org_affiliation: nil)
      if org_affiliation == :ratifying_provider
        org_ids = ProviderRelationshipPermissions.where(
          ratifying_provider_can_view_safeguarding_information: safeguarding_access,
        ).map(&:ratifying_provider_id)

        perms = ProviderPermissions.where(provider_id: org_ids).order('RANDOM()')

        # We always give precedence to the training_provider relationship
        # so exclude users who belong to both training and ratifying providers
        perms.all.find do |p|
          @provider_user = p.provider_user
          @course = Course.joins(:course_options).find_by(accredited_provider_id: p.provider.id)
          !@provider_user.providers.include? @course.provider
        end
      elsif org_affiliation == :training_provider
        org_ids = ProviderRelationshipPermissions.where(
          training_provider_can_view_safeguarding_information: safeguarding_access,
        ).map(&:training_provider_id)

        perm = ProviderPermissions.where(provider_id: org_ids).order('RANDOM()').first

        @provider_user = perm.provider_user if perm
        @course = perm.provider.courses.joins(:course_options).find_by('accredited_provider_id IS NOT NULL') if perm
      else
        perm = ProviderPermissions.find_by(
          provider: Provider.find_by_code('1N1'),
          view_safeguarding_information: safeguarding_access,
        )
        @provider_user = perm.provider_user if perm
        @course = perm.provider.courses.joins(:course_options).find_by('accredited_provider_id IS NULL') if perm
      end
    end

    def build_application_choice(safeguarding_status)
      return unless @course

      application_form = FactoryBot.build(
        :completed_application_form,
        safeguarding_status,
        application_choices_count: 0,
      )

      @application_choice = FactoryBot.build(
        :application_choice,
        course_option: @course.course_options.first,
        application_form: application_form,
      )
    end

    def render_component
      if @application_choice
        render ProviderInterface::SafeguardingDeclarationComponent.new(
          application_choice: @application_choice,
          current_provider_user: @provider_user,
        )
      else
        render template: 'support_interface/docs/setup_local_dev_data_again'
      end
    end
  end
end
