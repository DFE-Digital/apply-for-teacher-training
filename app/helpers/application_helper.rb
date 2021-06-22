module ApplicationHelper
  SERVICES = { candidate_interface: 'apply',
               provider_interface: 'manage',
               support_interface: 'support',
               api_docs: 'api' }.stringify_keys.freeze

  def browser_title
    page_browser_title = content_for(:browser_title).presence || content_for(:title)
    [page_browser_title, service_name, 'GOV.UK'].select(&:present?).join(' - ')
  end

  def service_name
    t("service_name.#{service_key}")
  end

  def service_key
    return SERVICES[current_namespace] if SERVICES.key?(current_namespace)

    'apply'
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
      'vendor_api_docs'
    elsif section == 'data-api'
      'data_api_docs'
    elsif section == 'register-api'
      'register_api_docs'
    elsif section == 'candidate-api'
      'candidate_api_docs'
    elsif section.present?
      "#{section}_interface"
    end
  end
end
