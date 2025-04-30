class NavigationItems
  NavigationItem = Struct.new(:text, :href, :active, :classes)

  class << self
    include Rails.application.routes.url_helpers
    include AbstractController::Translation

    def candidate_primary_navigation(current_candidate:, current_controller:)
      return [] unless current_candidate

      if current_candidate.current_application.any_offer_accepted?
        [
          {
            text: t('page_titles.offer_dashboard'),
            href: candidate_interface_application_offer_dashboard_path,
            active: true,
          },
        ]
      elsif current_candidate.current_application.carry_over?
        [
          {
            text: t('page_titles.your_applications'),
            href: candidate_interface_application_choices_path,
            active: true,
          },
        ]
      else
        [
          {
            text: t('page_titles.your_details'),
            href: candidate_interface_details_path,
            active: current_controller.respond_to?(:choices_controller?) ? !current_controller.choices_controller? : false,
          },
          {
            text: t('page_titles.your_applications'),
            href: candidate_interface_application_choices_path,
            active: current_controller.respond_to?(:choices_controller?) ? current_controller.choices_controller? : false,
          },
        ]
      end
    end

    def candidate(current_candidate:)
      if current_candidate.nil?
        []
      else
        sign_in_items(current_candidate)
      end
    end

    def for_support_primary_nav(current_support_user, current_controller)
      if current_support_user
        items = [
          {
            text: 'Candidates',
            href: support_interface_applications_path,
            active: active?(current_controller, %w[candidates import_references application_forms]),
          },
          {
            text: 'Providers',
            href: support_interface_providers_path,
            active: active?(current_controller, %w[providers course provider_users api_tokens]),
          },
          {
            text: 'Performance',
            href: support_interface_performance_path,
            active: active?(current_controller, %w[performance data_exports validation_errors email_log vendor_api_requests performance_dashboard]),
          },
          {
            text: 'Settings',
            href: support_interface_settings_path,
            active: active?(current_controller, %w[settings tasks support_users]),
          },
          {
            text: 'Documentation',
            href: support_interface_docs_path,
            active: active?(current_controller, %w[docs]),
          },
        ]

        if FeatureFlag.active?(:show_support_find_a_candidate)
          items << {
            text: 'Find a candidate',
            href: support_interface_find_candidates_path,
            active: active?(current_controller, %w[find_candidates]),
          }
        end

        items
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
        items << {
          text: 'Applications',
          href: provider_interface_applications_path,
          active: active?(
            current_controller,
            %w[
              application_choices
              decisions
              offer_changes
              notes
              interviews
              offers
              feedback
              conditions
              reconfirm_deferred_offers
              references
              courses
              study_modes
            ],
          ),
        }

        if CandidatePoolProviderOptIn.find_by(provider_id: current_provider_user.provider_ids).present?
          items << {
            text: 'Find candidates',
            href: provider_interface_candidate_pool_root_path,
            active: active?(current_controller, %w[candidates draft_invites]),
          }
        end

        items << {
          text: 'Interview schedule',
          href: provider_interface_interview_schedule_path,
          active: active?(current_controller, %w[interview_schedules]),
        }
        items << {
          text: 'Reports',
          href: provider_interface_reports_path,
          active: active?(
            current_controller,
            %w[
              reports
              application_data_export
              hesa_exports
              recruitment_performance_reports
              withdrawal_reports
              withdrawal_reasons_reports
              status_of_active_applications
              diversity_reports
            ],
          ),
        }
        items << {
          text: 'Activity log',
          href: provider_interface_activity_log_path,
          active: active?(current_controller, %w[activity_log]),
        }
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

    def sign_in_items(current_candidate)
      items = []

      if FeatureFlag.active?(:one_login_candidate_sign_in) && !OneLogin.bypass? && current_candidate.one_login_auth.present?
        items << NavigationItem.new("GOV.UK One Login #{one_login_svg}".html_safe, ENV['GOVUK_ONE_LOGIN_ACCOUNT_URL'])
      end

      sign_out_path = FeatureFlag.active?(:one_login_candidate_sign_in) ? auth_one_login_sign_out_path : candidate_interface_sign_out_path
      items << NavigationItem.new('Sign out', sign_out_path)
    end

    def one_login_svg
      "<span aria-hidden=\"true\" class=\"one-login-svg\">
        <svg width=\"15\" height=\"15\" viewBox=\"0 0 22 22\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\" focusable=\"false\" aria-hidden=\"true\">
          <circle cx=\"11\" cy=\"11\" r=\"11\" fill=\"white\" data-darkreader-inline-fill=\"\" style=\"--darkreader-inline-fill: #e8e6e3;\"></circle>
          <path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3.29297 18.8487C4.23255 15.4753 7.32741 13 11.0004 13C14.6731 13 17.7678 15.4749 18.7076 18.848C17.8058 19.7338 16.752 20.4654 15.5889 21H11.0004H6.41097C5.24819 20.4655 4.19463 19.7342 3.29297 18.8487Z\" fill=\"#1D70B8\" data-darkreader-inline-fill=\"\" style=\"--darkreader-inline-fill: #65aee7;\"></path>
          <circle cx=\"11\" cy=\"7.75\" r=\"3.75\" fill=\"#1D70B8\" data-darkreader-inline-fill=\"\" style=\"--darkreader-inline-fill: #65aee7;\"></circle>
          <circle cx=\"11\" cy=\"11\" r=\"10\" stroke=\"white\" stroke-width=\"2\" data-darkreader-inline-stroke=\"\" style=\"--darkreader-inline-stroke: #e8e6e3;\"></circle>
        </svg>
      </span><span class=\"govuk-visually-hidden\">Currently impersonating:</span>"
    end
  end
end
