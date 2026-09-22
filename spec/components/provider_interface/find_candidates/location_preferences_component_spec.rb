require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::LocationPreferencesComponent, type: :component do
  let(:application_form) { create(:application_form) }

  context 'specific locations' do
    it 'renders the locations' do
      candidate_preference = create(:candidate_preference, :specific_locations, application_form:)
      create(:candidate_location_preference, :manchester, candidate_preference:)
      create(:candidate_location_preference, :liverpool, candidate_preference:)

      render_inline(described_class.new(application_form:))

      expect(page).to have_text 'The candidate has said they can train in the following areas:'
      expect(page).to have_text 'Within 10.0 miles of Manchester'
      expect(page).to have_text 'Within 10.0 miles of Liverpool'
    end
  end

  context 'anywhere in england' do
    it 'does not render the locations' do
      create(:candidate_preference, :anywhere_in_england, application_form:)

      render_inline(described_class.new(application_form:))

      expect(page).to have_text 'The candidate has said they can train anywhere in England.'
    end
  end

  describe '#specific_locations?' do
    context 'when the candidate has no preferences' do
      it 'returns false' do
        expect(described_class.new(application_form:).specific_locations?).to be(false)
      end
    end

    context 'when the candidate has preferences is not specific' do
      before { create(:candidate_preference, :anywhere_in_england, application_form:) }

      it 'returns false' do
        expect(described_class.new(application_form:).specific_locations?).to be(false)
      end
    end

    context 'when the candidate has preferences has no specific locations' do
      before { create(:candidate_preference, :specific_locations, application_form:) }

      it 'returns false' do
        expect(described_class.new(application_form:).specific_locations?).to be(false)
      end
    end

    context 'when the candidate has preferences is specific to a location' do
      let(:candidate_preference) { create(:candidate_preference, :specific_locations, application_form:) }

      before do
        create(:candidate_location_preference, :manchester, candidate_preference:)
        create(:candidate_location_preference, :liverpool, candidate_preference:)
      end

      it 'returns true' do
        expect(described_class.new(application_form:).specific_locations?).to be(true)
      end
    end
  end
end
