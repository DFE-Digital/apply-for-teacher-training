require 'rails_helper'

RSpec.describe SupportInterface::ServiceBannerConfigurationComponent do
  context 'when the component is not enabled with no audit history' do
    it 'displays the default rows and text' do
      interface = 'support_console'

      result = render_inline(described_class.new(interface:))

      expect(result).to have_text('Support Console service banner')
      expect(result).to have_text('-')

      expect(result).to have_no_text('Banner content')
      expect(result).to have_no_text('Banner enabled by')
    end
  end

  context 'when the component is enabled with audit history' do
    it 'displays the default rows and text' do
      interface = 'manage'
      live_banner = create(:service_banner, :manage, status: 'published')
      support_user = create(:support_user, email_address: 'support@education.gov.uk')
      create(:audit, auditable_type: 'ServiceBanner', auditable_id: live_banner.id, user_id: support_user.id, user_type: 'SupportUser', action: 'update', audited_changes: { 'status' => %w[draft published] })

      result = render_inline(described_class.new(interface:))

      expect(result).to have_text('Manage service banner')
      expect(result).to have_text('The service will be unavailable this evening between 6pm and 9pm')
      expect(result).to have_text('You may lose data if you are processing applications at this time')
      expect(result).to have_text('Banner enabled by support@education.gov.uk')
    end
  end
end
