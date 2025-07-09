require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::RightToWorkComponent, type: :component do
  context 'candidates is british or irish' do
    it 'shows the immigration status' do
      application_form = build(:application_form, right_to_work_or_study: nil, first_nationality: 'British')

      render_inline(described_class.new(application_form:))

      expect(page).to have_content 'Not required'
      expect(page).to have_content 'Visa or immigration status'
      expect(page).to have_content 'British or Irish citizen'
    end
  end

  context 'candidates has visa and does not need sponsorship' do
    it 'renders immigration status' do
      application_form = build(:application_form, right_to_work_or_study: 'yes', immigration_status: 'indefinite_leave_to_remain_in_the_uk')

      render_inline(described_class.new(application_form:))

      expect(page).to have_content 'Not required'
      expect(page).to have_content 'Visa or immigration status'
      expect(page).to have_content 'Indefinite leave to remain in the UK'
    end
  end

  context 'candidate requires sponsorship' do
    it 'does not render immigration status' do
      application_form = build(:application_form, right_to_work_or_study: 'no')

      render_inline(described_class.new(application_form:))

      expect(page).to have_content 'Required'
      expect(page).to have_no_content 'Visa or immigration status'
    end
  end
end
