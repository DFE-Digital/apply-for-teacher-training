class ProviderInterface::CookiePreferencesController < ApplicationController
  include CookiePreferenceConcerns

  def consent_cookie
    'consented-to-manage-cookies'
  end

  def cookie_page_path
    provider_interface_cookies_path
  end
end
