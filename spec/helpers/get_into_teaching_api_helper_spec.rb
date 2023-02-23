require 'rails_helper'

RSpec.describe GetIntoTeachingAPIHelper do
  describe '#lookup_item_options' do
    let(:lookup_items) do
      [
        GetIntoTeachingApiClient::Country.new(value: 'United Kingdom'),
        GetIntoTeachingApiClient::Country.new(value: 'Australia'),
      ]
    end

    subject { lookup_item_options(lookup_items).map(&:name) }

    it { is_expected.to eq(lookup_items.map(&:value)) }
  end
end
