module ApplicationHelper
  def browser_title
    page_browser_title = content_for(:browser_title).presence || content_for(:title)
    [page_browser_title, service_name, 'GOV.UK'].select(&:present?).join(' - ')
  end

  def service_name
    case current_namespace
    when 'candidate_interface'
      t('service_name.apply')
    when 'provider_interface'
      t('service_name.manage')
    when 'support_interface'
      t('service_name.support')
    else
      t('service_name.apply')
    end
  end

  def service_link
    custom_link = content_for(:service_link)
    return custom_link if custom_link

    case current_namespace
    when 'provider_interface'
      provider_interface_path
    when 'candidate_interface'
      candidate_interface_start_path
    when 'support_interface'
      support_interface_path
    else
      root_path
    end
  end

  def current_namespace
    params[:controller].split('/').first
  end

  def full_name(application_form)
    "#{application_form.first_name} #{application_form.last_name}"
  end
end
