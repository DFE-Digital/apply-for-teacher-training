module CookiePreferenceConcerns
  def create
    @cookie_preferences = CookiePreferencesForm.new(consent: cookie_preferences_consent)
    cookies[consent_cookie] = { value: @cookie_preferences.consent, expires: 6.months.from_now }
    session[:display_cookie_consent_confirmation] = true

    flash[:success] = 'Your cookie preferences have been updated.'
    redirect_to session[:previous_referer].presence || root_path
  end

  def hide_confirmation
    session.delete(:display_cookie_consent_confirmation)

    redirect_back_or_to(root_path)
  end

private

  def cookie_preferences_consent
    cookie_preference_params = params.key?(:cookie_preferences_form) ? params[:cookie_preferences_form] : params
    cookie_preference_params.permit(:consent)[:consent]
  end
end
