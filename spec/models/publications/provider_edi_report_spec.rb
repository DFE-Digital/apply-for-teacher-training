require 'rails_helper'

RSpec.describe Publications::ProviderEdiReport do
  describe 'associations' do
    it { is_expected.to have_one :recruitment_cycle_timetable }
    it { is_expected.to belong_to :provider }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :publication_date }
    it { is_expected.to validate_presence_of :cycle_week }
    it { is_expected.to validate_presence_of :category }
  end

  describe 'enums' do
    subject(:provider_edi) { build(:provider_edi_report) }

    it {
      expect(provider_edi).to(
        define_enum_for(:category)
        .with_values(
          ethnic_group: 'Ethnic group',
          sex: 'Sex',
          age_group: 'Age group',
          disability: 'Disability',
        )
        .backed_by_column_of_type(:string),
      )
    }
  end
end
