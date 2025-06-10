require 'rails_helper'

RSpec.describe DataMigrations::BackfillTrainingLocationsOnCandidatePreferences do
  describe '#.change' do
    let(:published_no_locations_opt_in) do
      create(
        :candidate_preference,
        :published,
        :opt_in,
        training_locations: nil,
        location_preferences: [],
      )
    end
    let(:published_with_locations_opt_in) do
      create(
        :candidate_preference,
        :published,
        :opt_in,
        training_locations: nil,
        location_preferences: [build(:candidate_location_preference)],
      )
    end

    let(:published_with_locations_opt_out) do
      create(
        :candidate_preference,
        :published,
        :opt_out,
        training_locations: nil,
        location_preferences: [build(:candidate_location_preference)],
      )
    end
    let(:unpublished_no_locations) do
      create(
        :candidate_preference,
        :draft,
        :opt_in,
        training_locations: nil,
        location_preferences: [],
      )
    end

    let(:unpublished_with_locations) do
      create(
        :candidate_preference,
        :draft,
        :opt_in,
        training_locations: nil,
        location_preferences: [build(:candidate_location_preference)],
      )
    end

    before do
      published_no_locations_opt_in
      published_with_locations_opt_in
      published_with_locations_opt_out
      unpublished_no_locations
      unpublished_with_locations
    end

    it 'only updates published preferences that have opted in' do
      described_class.new.change
      expect(unpublished_no_locations.reload.training_locations).to be_nil
      expect(unpublished_with_locations.reload.training_locations).to be_nil
      expect(published_with_locations_opt_out.training_locations).to be_nil
    end

    it 'updates preferences without locations to "anywhere"' do
      described_class.new.change
      expect(published_no_locations_opt_in.reload.training_locations).to eq 'anywhere'
    end

    it 'updates preferences with locations to "specific"' do
      described_class.new.change
      expect(published_with_locations_opt_in.reload.training_locations).to eq 'specific'
    end
  end
end
