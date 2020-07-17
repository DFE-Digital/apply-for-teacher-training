class NavigationItems
  NavigationItem = Struct.new(:text, :href, :active)

  class << self
    include Rails.application.routes.url_helpers
    include AbstractController::Translation

    def for_candidate_interface(current_candidate, _current_controller)
      if current_candidate
        [
          NavigationItem.new(current_candidate.email_address, nil, false),
          NavigationItem.new('Sign out', candidate_interface_sign_out_path, false),
        ]
      else
        [
          NavigationItem.new('Sign in', candidate_interface_sign_in_path, false),
        ]
      end
    end

    def for_support_interface(current_support_user, current_controller)
      if current_support_user
        [
          NavigationItem.new('Candidates', support_interface_candidates_path, is_active(current_controller, %w[candidates import_references])),
          NavigationItem.new('API Tokens', support_interface_tokens_path, is_active(current_controller, 'api_tokens')),
          NavigationItem.new('Providers', support_interface_providers_path, is_active(current_controller, %w[providers courses])),
          NavigationItem.new('Features', support_interface_feature_flags_path, is_active(current_controller, 'feature_flags')),
          NavigationItem.new('Performance', support_interface_performance_path, is_active(current_controller, %w[performance course_options])),
          NavigationItem.new('Tasks', support_interface_tasks_path, is_active(current_controller, 'tasks')),
          NavigationItem.new('Users', support_interface_users_path, is_active(current_controller, 'users')),
          NavigationItem.new(current_support_user.email_address, nil, false),
          NavigationItem.new('Sign out', support_interface_sign_out_path, false),
        ]
      else
        []
      end
    end

    def for_provider_primary_nav(current_controller)
      [NavigationItem.new('Applications', provider_interface_applications_path, is_active(current_controller, %w[application_choices decisions offer_changes]))]
    end

    def for_provider_account_nav(current_provider_user, current_controller)
      return [NavigationItem.new('Sign in', provider_interface_sign_in_path, false)] unless current_provider_user

      items = []

      if current_provider_user.can_manage_organisations? && Provider.with_permissions_visible_to(current_provider_user).exists?
        items << NavigationItem.new('Organisations', provider_interface_organisations_path, is_active(current_controller, %w[organisations provider_relationship_permissions]))
      end

      if FeatureFlag.active?(:providers_can_manage_users_and_permissions) && current_provider_user.can_manage_users?
        items << NavigationItem.new('Users', provider_interface_provider_users_path, is_active(current_controller, 'provider_users'))
      end

      items << NavigationItem.new('Account', provider_interface_account_path, is_active(current_controller, 'account'))
      items << NavigationItem.new('Sign out', provider_interface_sign_out_path, false)
    end

    def for_api_docs(current_controller)
      [
        NavigationItem.new('Home', api_docs_home_path, is_active_action(current_controller, 'home')),
        NavigationItem.new(t('page_titles.api_docs.usage'), api_docs_usage_path, is_active_action(current_controller, 'usage')),
        NavigationItem.new(t('page_titles.api_docs.reference'), api_docs_reference_path, is_active_action(current_controller, 'reference')),
        NavigationItem.new(t('page_titles.api_docs.release_notes'), api_docs_release_notes_path, is_active_action(current_controller, 'release_notes')),
        NavigationItem.new(t('page_titles.api_docs.lifecycle'), api_docs_lifecycle_path, is_active_action(current_controller, 'lifecycle')),
        NavigationItem.new(t('page_titles.api_docs.help'), api_docs_help_path, is_active_action(current_controller, 'help')),
      ]
    end

  private

    def is_active(current_controller, active_controllers)
      current_controller.controller_name.in?(Array.wrap(active_controllers))
    end

    def is_active_action(current_controller, active_action)
      current_controller.action_name == active_action
    end
  end
end
