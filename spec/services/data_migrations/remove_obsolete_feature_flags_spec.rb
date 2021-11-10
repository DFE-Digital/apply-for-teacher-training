require 'rails_helper'

RSpec.describe DataMigrations::RemoveObsoleteFeatureFlags do
  let(:obsolete_feature_count) { 10 }
  let!(:obsolete_features) { create_list(:feature, obsolete_feature_count) }
  let!(:features) { FeatureFlag::FEATURES.map { |feature| Feature.find_or_create_by(name: feature.first) } }

  it 'deletes any obsolete features from the database' do
    expect(Feature.count).to eq(features.length + obsolete_feature_count)

    described_class.new.change

    expect(Feature.count).to eq(features.length)
  end
end
