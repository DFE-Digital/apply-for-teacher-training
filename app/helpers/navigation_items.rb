class NavigationItems
  NavigationItem = Struct.new(:text, :href, :active, :classes)

  class << self
    include Rails.application.routes.url_helpers
    include AbstractController::Translation

    def candidate_primary_navigation(current_candidate:, current_controller:)
      return [] unless current_candidate

      if current_candidate.current_application.any_offer_accepted?
        [
          NavigationItem.new(
            t('page_titles.offer_dashboard'),
            candidate_interface_application_offer_dashboard_path,
            true,
          ),
        ]
      elsif current_candidate.current_application.carry_over?
        [
          NavigationItem.new(
            t('page_titles.your_applications'),
            candidate_interface_application_choices_path,
            true,
          ),
        ]
      else
        [
          NavigationItem.new(
            t('page_titles.your_details'),
            candidate_interface_details_path,
            current_controller.respond_to?(:choices_controller?) ? !current_controller.choices_controller? : false,
          ),
          NavigationItem.new(
            t('page_titles.your_applications'),
            candidate_interface_application_choices_path,
            current_controller.respond_to?(:choices_controller?) ? current_controller.choices_controller? : false,
          ),
        ]
      end
    end

    def for_support_primary_nav(current_support_user, current_controller)
      if current_support_user
        [
          NavigationItem.new('Candidates', support_interface_applications_path, active?(current_controller, %w[candidates import_references application_forms]), []),
          NavigationItem.new('Providers', support_interface_providers_path, active?(current_controller, %w[providers course provider_users api_tokens]), []),
          NavigationItem.new('Performance', support_interface_performance_path, active?(current_controller, %w[performance data_exports validation_errors email_log vendor_api_requests performance_dashboard]), []),
          NavigationItem.new('Settings', support_interface_settings_path, active?(current_controller, %w[settings tasks support_users]), []),
          NavigationItem.new('Documentation', support_interface_docs_path, active?(current_controller, %w[docs]), []),
        ]
      else
        []
      end
    end

    def for_support_account_nav(current_support_user)
      if current_support_user && (impersonated_user = current_support_user.impersonated_provider_user)
        [
          NavigationItem.new("<span aria-hidden=\"true\">🎭 ⚙️</span><span class=\"govuk-visually-hidden\">Currently impersonating: #{impersonated_user.email_address}</span>".html_safe, support_interface_provider_user_path(impersonated_user), false, []),
          NavigationItem.new(current_support_user.email_address, nil, false, []),
          NavigationItem.new('Sign out', support_interface_sign_out_path, false, []),
        ]
      elsif current_support_user
        [
          NavigationItem.new(current_support_user.email_address, nil, false, []),
          NavigationItem.new('Sign out', support_interface_sign_out_path, false, []),
        ]
      else
        []
      end
    end

    def for_provider_primary_nav(current_provider_user, current_controller, performing_setup: false)
      items = []

      if current_provider_user && !performing_setup
        items << NavigationItem.new('Applications', provider_interface_applications_path, active?(current_controller, %w[application_choices decisions offer_changes notes interviews offers feedback conditions reconfirm_deferred_offers]), [])
        items << NavigationItem.new('Interview schedule', provider_interface_interview_schedule_path, active?(current_controller, %w[interview_schedules]), [])
        items << NavigationItem.new('Reports', provider_interface_reports_path, active?(current_controller, %w[reports application_data_export hesa_exports recruitment_performance_reports withdrawal_reports withdrawal_reasons_reports status_of_active_applications diversity_reports]))
        items << NavigationItem.new('Activity log', provider_interface_activity_log_path, active?(current_controller, %w[activity_log]), [])
      end

      items
    end

    def for_provider_account_nav(current_provider_user, current_controller, performing_setup: false)
      return [] if (active_action?(current_controller, 'new') && active?(current_controller, 'sessions')) || active_action?(current_controller, 'sign_in_by_email')

      return [NavigationItem.new('Sign in', provider_interface_sign_in_path, false, [])] unless current_provider_user

      items = []

      unless performing_setup
        items << NavigationItem.new(t('page_titles.provider.organisation_settings'), provider_interface_organisation_settings_path, active?(current_controller, %w[organisation_settings organisations provider_users provider_relationship_permissions]), [])

        items << NavigationItem.new(t('page_titles.provider.account'), provider_interface_account_path, active?(current_controller, %w[account profile notifications]), [])
      end

      sign_out_navigation = if current_provider_user.impersonator
                              NavigationItem.new('Support',
                                                 support_interface_provider_user_path(current_provider_user),
                                                 false, [])
                            else
                              NavigationItem.new('Sign out',
                                                 provider_interface_sign_out_path,
                                                 false, [])
                            end
      items << sign_out_navigation
    end

    def for_vendor_api_docs(current_controller)
      items = [
        NavigationItem.new('Home', api_docs_home_path, active_action?(current_controller, 'home'), []),
        NavigationItem.new(t('page_titles.api_docs.vendor_api_docs.usage'), api_docs_usage_path, active_action?(current_controller, 'usage'), []),
        NavigationItem.new(t('page_titles.api_docs.vendor_api_docs.reference'), api_docs_reference_path, active_action?(current_controller, 'reference'), []),
        NavigationItem.new(t('page_titles.api_docs.vendor_api_docs.release_notes'), api_docs_release_notes_path, active_action?(current_controller, 'release_notes'), []),
        NavigationItem.new(t('page_titles.api_docs.vendor_api_docs.lifecycle'), api_docs_lifecycle_path, active_action?(current_controller, 'lifecycle'), []),
        NavigationItem.new(t('page_titles.api_docs.vendor_api_docs.help'), api_docs_help_path, active_action?(current_controller, 'help'), []),
      ]

      items << NavigationItem.new(t('page_titles.api_docs.vendor_api_docs.draft'), api_docs_draft_path, active_action?(current_controller, 'draft'), []) if FeatureFlag.active?(:draft_vendor_api_specification)

      items
    end

    def for_register_api_docs(current_controller)
      [
        NavigationItem.new('Home', api_docs_register_api_docs_home_path, active_action?(current_controller, 'reference'), []),
        NavigationItem.new('Release notes', api_docs_register_api_docs_release_notes_path, active_action?(current_controller, 'release_notes'), []),
      ]
    end

  private

    def active?(current_controller, active_controllers)
      current_controller.controller_name.in?(Array.wrap(active_controllers))
    end

    def active_action?(current_controller, active_action)
      current_controller.action_name == active_action
    end
  end
end
