require 'rails_helper'

module SupportInterface
  RSpec.describe RegionalReportForm, type: :model do
    subject(:form) { described_class.new(params) }
    let(:params) { { region: 'London' } }

    describe '#options' do
      it 'returns the form options' do
        expect(form.options).to eq(expected_options)
      end
    end

    describe '#save' do
      it 'returns true if valid' do
        expect(form.save).to be(true)
      end

      context 'when invalid' do
        let(:params) { { region: nil } }

        it 'returns false' do
          expect(form.save).to be(false)
        end
      end
    end

  private

    def expected_options
      [
        SupportInterface::RegionalReportForm::Region.new(
          label: 'All of England',
          value: 'all_of_england',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'West Midlands (England)',
          value: 'west_midlands',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'North West (England)',
          value: 'north_west',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'London',
          value: 'london',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'North East (England)',
          value: 'north_east',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'South West (England)',
          value: 'south_west',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'East Midlands (England)',
          value: 'east_midlands',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'East of England',
          value: 'east_of_england',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'Yorkshire and The Humber',
          value: 'yorkshire_and_the_humber',
        ),
        SupportInterface::RegionalReportForm::Region.new(
          label: 'South East (England)',
          value: 'south_east',
        ),
      ]
    end
  end
end
