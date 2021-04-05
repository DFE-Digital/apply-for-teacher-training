module CookiePreferenceConcerns
  def create
    @cookie_preferences = CookiePreferencesForm.new(consent: cookie_preferences_consent)
    cookies[consent_cookie] = { value: @cookie_preferences.consent, expires: 6.months.from_now }
    session[:display_cookie_consent_confirmation] = true

    link_to_previous_referer
    redirect_back(fallback_location: cookie_page_path)
  end

  def hide_confirmation
    session.delete(:display_cookie_consent_confirmation)

    redirect_back(fallback_location: root_path)
  end

private

  def cookie_preferences_consent
    cookie_preference_params = params.key?(:cookie_preferences_form) ? params[:cookie_preferences_form] : params
    cookie_preference_params.permit(:consent)[:consent]
  end

  def link_to_previous_referer
    request_uri = URI(request.referer).request_uri
    previous_referer_uri = URI(session[:previous_referer]).request_uri if session[:previous_referer].present?

    if previous_referer_uri && request_uri.eql?(cookie_page_path) && !previous_referer_uri.eql?(cookie_page_path)
      flash[:success] = 'Your cookie preferences have been updated.'
      flash[:link] = {
        text: 'Go back to the page you were looking at',
        url: session[:previous_referer],
      }
      session.delete(:previous_referer)
    end
  end
end
