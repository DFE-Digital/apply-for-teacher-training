require 'rails_helper'

module Shared
  RSpec.describe ProviderRegionalReportForm, type: :model do
    describe '#save' do
      context 'when invalid' do
        it 'returns nil' do
          form = described_class.new({ region: nil })
          expect(form.save).to be_nil
        end
      end

      context 'when there is a reginal filter record' do
        it 'returns the saved db filter' do
          filter = create(:regional_report_filter)
          form = described_class.new(
            {
              region: filter.region,
              provider_id: filter.provider_id,
              provider_user_id: filter.provider_user_id,
            },
          )

          expect(form.save).to eq(filter)
        end
      end

      context 'when there is a reginal filter record for same user but it is different' do
        it 'returns the new filter and removes the old' do
          provider_user = create(:provider_user, :with_provider)
          existing_filter = create(
            :regional_report_filter,
            provider_user:,
            provider: provider_user.providers.last,
          )
          different_user_filter = create(:regional_report_filter)

          form = described_class.new(
            {
              region: 'all_of_england',
              provider_id: existing_filter.provider_id,
              provider_user_id: existing_filter.provider_user_id,
            },
          )

          form.save
          expect(provider_user.regional_report_filters.last.region).to eq(
            'all_of_england',
          )
          expect(RegionalReportFilter.exists?(existing_filter.id)).to be(false)
          expect(RegionalReportFilter.exists?(different_user_filter.id)).to be(true)
        end
      end

      context 'when there is no regional filter in db' do
        it 'creates one and returns it' do
          provider_user = create(:provider_user, :with_provider)
          provider = provider_user.providers.last

          form = described_class.new(
            {
              region: 'all_of_england',
              provider_id: provider.id,
              provider_user_id: provider_user.id,
            },
          )

          new_filter = form.save
          expect(new_filter.region).to eq('all_of_england')
          expect(new_filter.provider).to eq(provider)
          expect(new_filter.provider_user).to eq(provider_user)
        end
      end
    end

    describe '.initialize_from_report_filter' do
      it 'builds the form from the report filter db record' do
        report_filter = create(:regional_report_filter)

        report_form = described_class.initialize_from_report_filter(
          provider_id: report_filter.provider_id,
          provider_user_id: report_filter.provider_user.id,
        )

        expect(report_form.region).to eq('london')
      end
    end
  end
end
