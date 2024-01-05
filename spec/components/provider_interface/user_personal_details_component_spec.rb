require 'rails_helper'

RSpec.describe ProviderInterface::UserPersonalDetailsComponent do
  let(:change_path) { nil }
  let(:user) { build_stubbed(:provider_user) }

  subject!(:render) { render_inline(described_class.new(user:, change_path:)) }

  it 'renders each field with the correct values' do
    expect(render.css('.govuk-summary-list__row')[0].text).to include('First name', user.first_name)
    expect(render.css('.govuk-summary-list__row')[1].text).to include('Last name', user.last_name)
    expect(render.css('.govuk-summary-list__row')[2].text).to include('Email address', user.email_address)
  end

  context 'when the change_path is nil' do
    it 'does not render change links' do
      expect(page).to have_no_link
    end
  end

  context 'when the change_path is given' do
    let(:change_path) { '/change-path' }

    it 'renders change links' do
      expect(page).to have_link('Change First name', href: change_path)
      expect(page).to have_link('Change Last name', href: change_path)
      expect(page).to have_link('Change Email address', href: change_path)
    end
  end
end
