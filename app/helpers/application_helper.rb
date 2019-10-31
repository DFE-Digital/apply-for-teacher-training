module ApplicationHelper
  def page_title(page)
    page_title_translation_key = "page_titles.#{page}"

    if I18n.exists?(page_title_translation_key)
      "#{t(page_title_translation_key)} - #{t('page_titles.application')}"
    else
      t('page_titles.application')
    end
  end

  def service_name
    case current_namespace
    when 'provider_interface'
      'Manage teacher training applications'
    when 'candidate_interface'
      'Apply for teacher training'
    when 'support_interface'
      'Support'
    else
      'Apply for teacher training'
    end
  end

  def service_link
    case current_namespace
    when 'provider_interface'
      provider_interface_path
    when 'candidate_interface'
      if candidate_signed_in?
        candidate_interface_application_form_path
      else
        candidate_interface_start_path
      end
    when 'support_interface'
      support_interface_path
    else
      root_path
    end
  end

  def current_namespace
    params[:controller].split('/').first
  end

  def heading_for_gcse_edit_type(subject)
    t("gcse_edit_type.heading.#{subject}")
  end

  def heading_for_gcse_edit_details(subject)
    t("gcse_edit_details.heading.#{subject}")
  end

  def heading_for_gcse_show(subject)
    t("gcse_summary.heading.#{subject}")
  end
end
