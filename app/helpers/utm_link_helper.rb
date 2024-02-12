module UtmLinkHelper
  UTM_PARAMS = {
    utm_source: 'apply-for-teacher-training.service.gov.uk',
    utm_medium: 'referral',
  }.freeze

  def govuk_link_to_with_utm_params(link_text, link_url, utm_campaign, utm_content = nil, **extra_options)
    url = construct_url(link_url, utm_campaign, utm_content)
    govuk_link_to link_text.to_s, url.to_s, **extra_options
  end

  def email_link_with_utm_params(link_url, utm_campaign, utm_content)
    url = construct_url(link_url, utm_campaign, utm_content)
    url.to_s
  end

  def utm_campaign(params)
    params.slice(:controller, :action).values.join('-')
  end

private

  def construct_url(link_url, utm_campaign, utm_content)
    return link_url unless HostingEnvironment.production?

    uri = URI.parse(link_url)
    encoded_utm_campaign = CGI.escape(utm_campaign)
    uri.query = "utm_source=#{UTM_PARAMS[:utm_source]}&utm_medium=#{UTM_PARAMS[:utm_medium]}&utm_campaign=#{encoded_utm_campaign}&utm_content=#{utm_content}"
    uri
  end
end
