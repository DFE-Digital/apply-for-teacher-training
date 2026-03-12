class CookieBannersComponent < ApplicationComponent
  include ApplicationHelper

  CANDIDATE_INTERFACE = 'candidate_interface'.freeze
  PROVIDER_INTERFACE = 'provider_interface'.freeze
  RELEVANT_COOKIES = %w[consented-to-apply-cookies consented-to-manage-cookies].freeze

  def initialize(current_namespace:, request_path:, cookies: nil)
    @current_namespace = current_namespace
    @request_path = request_path
    @cookies = cookies
  end

  def render?
    valid_page? && valid_namespace? && cookies_have_not_been_set?
  end

  def service_name_short
    current_namespace == CANDIDATE_INTERFACE ? 'apply' : 'manage'
  end

  def namespace_cookies_path
    if current_namespace == CANDIDATE_INTERFACE
      url_helpers.candidate_interface_cookies_path
    else
      url_helpers.provider_interface_cookies_path
    end
  end

private

  def valid_page?
    !request_path.eql?(url_helpers.candidate_interface_cookies_path) && !request.path.eql?(url_helpers.provider_interface_cookies_path)
  end

  def valid_namespace?
    current_namespace.eql?(CANDIDATE_INTERFACE) || current_namespace.eql?(PROVIDER_INTERFACE)
  end

  def cookies_have_not_been_set?
    return true if cookies.blank?

    cookies.to_h.keys.none? { |c| RELEVANT_COOKIES.include?(c) }
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  attr_reader :current_namespace, :request_path, :cookies
end
