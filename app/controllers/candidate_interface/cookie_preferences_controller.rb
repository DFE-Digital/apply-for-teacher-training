class CandidateInterface::CookiePreferencesController < ApplicationController
  include CookiePreferenceConcerns

  def consent_cookie
    'consented-to-apply-cookies'
  end

  def cookie_page_path
    candidate_interface_cookies_path
  end
end
