module ApplicationHelper
  include Pagy::Frontend

  SERVICES = { candidate_interface: 'apply',
               provider_interface: 'manage',
               support_interface: 'support',
               api_docs: 'api' }.stringify_keys.freeze

  def browser_title
    page_browser_title = content_for(:browser_title).presence || content_for(:title)
    [page_browser_title, service_name, 'GOV.UK'].compact_blank.join(' - ').html_safe
  end

  def service_name
    t("service_name.#{service_key}")
  end

  def service_key
    return SERVICES[current_namespace] if SERVICES.key?(current_namespace)

    'apply'
  end

  def find_url
    if HostingEnvironment.sandbox_mode?
      t('find_teacher_training.sandbox_url')
    elsif HostingEnvironment.qa?
      t('find_teacher_training.qa_url')
    else
      t('find_teacher_training.production_url')
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
      'vendor_api_docs'
    elsif section == 'data-api'
      'data_api_docs'
    elsif section == 'register-api'
      'register_api_docs'
    elsif section == 'candidate-api'
      'candidate_api_docs'
    elsif section == 'publications'
      'publications'
    elsif section.present?
      "#{section}_interface"
    end
  end

  def max_course_choices
    ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES
  end

  def markdown(source)
    render = Govuk::MarkdownRenderer
    # Options: https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
    # lax_spacing: HTML blocks do not require to be surrounded by an empty line as in the Markdown standard.
    # autolink: parse links even when they are not enclosed in <> characters
    options = { autolink: true, lax_spacing: true }
    markdown = Redcarpet::Markdown.new(render, options)

    # Fix common markdown errors:
    # - using bullets rather than *
    # - not putting a space between * and word
    source = source.gsub(/•\s?/, '* ').gsub(/^\*(?![\s*])/, '* ')

    # Convert quotes to smart quotes
    source_with_smart_quotes = smart_quotes(source)
    markdown.render(source_with_smart_quotes).html_safe
  end

  def smart_quotes(string)
    return '' if string.blank?

    RubyPants.new(string, [2, :dashes], ruby_pants_options).to_html
  end

  def pg_now
    Time.zone.now.iso8601(6)
  end

  def start_date_field_to_attribute(key, start_date_param_name = 'start_date')
    case key
    when "#{start_date_param_name}(3i)" then 'start_date_day'
    when "#{start_date_param_name}(2i)" then 'start_date_month'
    when "#{start_date_param_name}(1i)" then 'start_date_year'
    else key
    end
  end

  def end_date_field_to_attribute(key, end_date_param_name = 'end_date')
    case key
    when "#{end_date_param_name}(3i)" then 'end_date_day'
    when "#{end_date_param_name}(2i)" then 'end_date_month'
    when "#{end_date_param_name}(1i)" then 'end_date_year'
    else key
    end
  end

  def valid_app_path(path)
    return false unless path.is_a?(String) && path.present?

    route_hash = Rails.application.routes.recognize_path(path)

    route_hash[:controller] != 'errors' && route_hash[:action] != 'not_found'
  rescue ActionController::RoutingError
    false
  end

private

  # Use characters rather than HTML entities for smart quotes this matches how
  # we write smart quotes in templates and allows us to use them in <title>
  # elements
  # https://github.com/jmcnevin/rubypants/blob/master/lib/rubypants.rb
  def ruby_pants_options
    {
      double_left_quote: '“',
      double_right_quote: '”',
      single_left_quote: '‘',
      single_right_quote: '’',
      ellipsis: '…',
      em_dash: '—',
      en_dash: '–',
    }
  end
end
