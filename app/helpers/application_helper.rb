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
    when 'api_docs'
      t('service_name.api')
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
      candidate_interface_create_account_or_sign_in_path
    when 'support_interface'
      support_interface_path
    else
      root_path
    end
  end

  def current_namespace
    section = request.path.split('/').second
    if section == 'api-docs'
      'api_docs'
    elsif section == 'data-api'
      'data_api_docs'
    else
      "#{section}_interface"
    end
  end
end
