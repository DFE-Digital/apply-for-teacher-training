require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationDataExportForm do
  context 'when there are application choices' do
    let(:provider) { create(:provider) }
    let(:provider_user) { create(:provider_user, providers: [provider]) }

    let(:application_form) { create(:completed_application_form, :with_degree) }
    let!(:application_choice) do
      create(
        :application_choice,
        :offered,
        application_form: application_form,
        provider_ids: [provider.id],
      )
    end

    let!(:maths_gcse) do
      create(:gcse_qualification, application_form:, subject: 'maths', grade: 'B', award_year: 2019)
    end

    let!(:english_gcse) do
      create(:gcse_qualification, application_form:, subject: 'english', grade: 'A', award_year: 2019)
    end

    it 'returns only the years where there are application choices' do
      form = described_class.new(current_provider_user: provider_user)

      years = form.years_to_export

      expect(years.keys.map(&:to_i)).to include(application_choice.current_recruitment_cycle_year)
    end
  end
end
