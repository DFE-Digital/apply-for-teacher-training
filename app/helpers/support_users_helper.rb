module SupportUsersHelper
  def support_user_account_management_path(support_user)
    if support_user.discarded?
      support_interface_confirm_restore_support_user_path(support_user)
    else
      support_interface_confirm_destroy_support_user_path(support_user)
    end
  end

  def support_user_provider_nav_items(support_user, report_current = nil)
    items = []

    items << { name: 'Details', url: support_interface_provider_path } if view_provider?(support_user)
    items << { name: 'Applications', url: support_interface_provider_applications_path } if view_applications?(support_user)
    items << { name: 'Users', url: support_interface_provider_user_list_path } if view_provider_users?(support_user)
    if view_provider?(support_user)
      provider_items = [
        { name: 'Courses', url: support_interface_provider_courses_path },
        { name: 'Relationships', url: support_interface_provider_relationships_path },
        { name: 'Ratified courses', url: support_interface_provider_ratified_courses_path },
        { name: 'Vacancies', url: support_interface_provider_vacancies_path },
        { name: 'Sites', url: support_interface_provider_sites_path },
        { name: 'History', url: support_interface_provider_history_path },
        { name: 'Reports', url: support_interface_provider_reports_path, current: report_current },
      ]
      items += provider_items
    end
    items
  end

private

  def view_provider?(support_user)
    @view_provider ||= SupportInterface::ProviderPolicy.new(support_user, nil).show?
  end

  def view_provider_users?(support_user)
    @view_provider ||= SupportInterface::ProviderUserPolicy.new(support_user, nil).show?
  end

  def view_applications?(support_user)
    @view_applications ||= SupportInterface::CandidatePolicy.new(support_user, nil).show?
  end

  def view_reports?(support_user)
    @view_applications ||= SupportInterface::ReportPolicy.new(support_user, nil).show?
  end
end
