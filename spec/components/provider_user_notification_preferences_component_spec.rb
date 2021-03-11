require 'rails_helper'

RSpec.describe ProviderUserNotificationPreferencesComponent do
  let(:provider_user) { create(:provider_user, send_notifications: true) }
  let(:notification_preferences) { provider_user.notification_preferences }

  it 'renders correct labels for notification preferences' do
    result = render_inline(described_class.new(notification_preferences, form_path: '/provider/account/notification-settings'))

    expect(result.css(:legend, '#govuk-fieldset__legend govuk-fieldset__legend--m')[0].text).to include('Application received')
    expect(result.css(:legend, '#govuk-fieldset__legend govuk-fieldset__legend--m')[1].text).to include('Application withdrawn by candidate')
    expect(result.css(:legend, '#govuk-fieldset__legend govuk-fieldset__legend--m')[2].text).to include('Application automatically rejected')
    expect(result.css(:legend, '#govuk-fieldset__legend govuk-fieldset__legend--m')[3].text).to include('Offer accepted')
    expect(result.css(:legend, '#govuk-fieldset__legend govuk-fieldset__legend--m')[4].text).to include('Offer declined')
  end

  it 'renders on and off radio buttons' do
    result = render_inline(described_class.new(notification_preferences, form_path: '/provider/account/notification-settings'))

    expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text).uniq).to match_array(%w[On Off])
  end
end
