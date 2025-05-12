require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::GcseQualificationsTableComponent, type: :component do
  context 'when enic has been obtained' do
    let(:international_gcse) do
      create(:gcse_qualification, :non_uk, enic_reference: '4120228363', subject: 'maths')
    end

    it 'renders additional enic text' do
      application_form = international_gcse.application_form

      render_inline(described_class.new(application_form))
      expect(page).to have_content 'Comparability statement for Maths'
      expect(page).to have_content 'UK ENIC or NARIC statement 4120228363 says this is comparable to Between GCSE and GCSE AS Level'
    end

    it 'removes bottom border border between cells when enic text present' do
      application_form = international_gcse.application_form

      render_inline(described_class.new(application_form))
      expect(page).to have_css('.qualifications-table__cell--no-bottom-border')
    end
  end
end
