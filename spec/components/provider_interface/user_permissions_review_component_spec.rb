require 'rails_helper'

RSpec.describe ProviderInterface::UserPermissionsReviewComponent do
  let(:permissions) { %w[make_decisions] }
  let(:change_path) { '/path' }
  let(:render) { render_inline(described_class.new(permissions:, change_path:)) }

  describe 'change link' do
    it 'links to the given path' do
      expect(render.css('a').first.attributes['href'].value).to eq(change_path)
    end

    it 'contains the correct text' do
      expect(render.css('a').first.text).to eq('Change Manage users')
    end
  end

  describe 'permission values' do
    it 'renders No in the row for a permission that is not in the array' do
      manage_users_row = render.css('.govuk-summary-list__row').find { |row| row.text.include? 'Manage users' }
      expect(manage_users_row.css('.govuk-summary-list__value').text.squish).to eq('No')
    end

    it 'renders Yes in the row for a permission that is in the array' do
      make_decisions_row = render.css('.govuk-summary-list__row').find { |row| row.text.include? 'Send offers, invitations and rejections' }
      expect(make_decisions_row.css('.govuk-summary-list__value').text.squish).to eq('Yes')
    end
  end
end
