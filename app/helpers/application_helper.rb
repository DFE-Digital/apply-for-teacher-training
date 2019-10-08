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
    end
  end

  def service_link
    case current_namespace
    when 'provider_interface'
      provider_interface_path
    when 'candidate_interface'
      candidate_interface_start_path
    end
  end

  def current_namespace
    params[:controller].split('/').first
  end
end
