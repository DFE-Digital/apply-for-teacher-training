require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::DegreesTableComponent, type: :component do
  describe 'additional enic text' do
    let(:international_degree) do
      create(:non_uk_degree_qualification, enic_reference: 4120228363, comparable_uk_degree: 'bachelor_ordinary_degree')
    end

    it 'renders additional enic text' do
      application_form = international_degree.application_form

      render_inline(described_class.new(application_form))
      expect(page).to have_content "Comparability statement for #{international_degree.subject}"
      expect(page).to have_content 'UK ENIC or NARIC statement 4120228363 says this is comparable to a Bachelor (Ordinary) degree'
    end

    it 'removes bottom border border between cells when enic text present' do
      application_form = international_degree.application_form

      render_inline(described_class.new(application_form))

      expect(page).to have_css('.qualifications-table__cell--no-bottom-border')
    end
  end
end
