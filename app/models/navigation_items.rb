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
        []
      end
    end

    def for_support_interface(current_support_user, current_controller)
      if current_support_user
        [
          NavigationItem.new('Candidates', support_interface_candidates_path, is_active(current_controller, %w[candidates import_references])),
          NavigationItem.new('API Tokens', support_interface_tokens_path, is_active(current_controller, 'api_tokens')),
          NavigationItem.new('Providers', support_interface_providers_path, is_active(current_controller, 'providers')),
          NavigationItem.new('Features', support_interface_feature_flags_path, is_active(current_controller, 'feature_flags')),
          NavigationItem.new('Performance', support_interface_performance_path, is_active(current_controller, 'performance')),
          NavigationItem.new('Tasks', support_interface_tasks_path, is_active(current_controller, 'tasks')),
          NavigationItem.new('Users', support_interface_users_path, is_active(current_controller, 'users')),
          NavigationItem.new(current_support_user.email_address, nil, false),
          NavigationItem.new('Sign out', support_interface_sign_out_path, false),
        ]
      else
        []
      end
    end

    def for_provider_interface(current_provider_user)
      if current_provider_user
        [
          NavigationItem.new(current_provider_user.email_address, nil, false),
          NavigationItem.new('Sign out', provider_interface_sign_out_path, false),
        ]
      else
        []
      end
    end

    def for_api_docs(current_controller)
      [
        NavigationItem.new('Home', api_docs_home_path, is_active_action(current_controller, 'home')),
        NavigationItem.new(t('page_titles.api_docs.usage'), api_docs_usage_path, is_active_action(current_controller, 'usage')),
        NavigationItem.new(t('page_titles.api_docs.reference'), api_docs_reference_path, is_active_action(current_controller, 'reference')),
        NavigationItem.new(t('page_titles.api_docs.release_notes'), api_docs_release_notes_path, is_active_action(current_controller, 'release_notes')),
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
