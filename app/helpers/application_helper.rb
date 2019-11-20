module ApplicationHelper
  def page_title(page)
    page_title_translation_key = "page_titles.#{page}"

    if I18n.exists?(page_title_translation_key)
      "#{t(page_title_translation_key)} - #{t('page_titles.application')}"
    else
      t('page_titles.application')
    end
  end

  def browser_title
    page_browser_title = content_for(:browser_title).presence || content_for(:title)
    [page_browser_title, service_name, 'GOV.UK'].select(&:present?).join(' - ')
  end

  def service_name
    case current_namespace
    when 'provider_interface'
      'Manage teacher training applications'
    when 'candidate_interface'
      'Apply for teacher training'
    when 'support_interface'
      'Support for Apply'
    else
      'Apply for teacher training'
    end
  end

  def service_link
    custom_link = content_for(:service_link)
    return custom_link if custom_link

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
end
