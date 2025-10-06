require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::LocationPreferencesComponent, type: :component do
  context 'specific locations' do
    it 'renders the locations' do
      application_form = create(:application_form)
      candidate_preference = create(:candidate_preference, :specific_locations, application_form:)
      create(:candidate_location_preference, :manchester, candidate_preference:)
      create(:candidate_location_preference, :liverpool, candidate_preference:)

      render_inline(described_class.new(application_form:))

      expect(page).to have_content 'The candidate has said they can train in the following areas:'
      expect(page).to have_content 'Within 10.0 miles of Manchester'
      expect(page).to have_content 'Within 10.0 miles of Liverpool'
    end
  end

  context 'anywhere in england' do
    it 'does not render the locations' do
      application_form = create(:application_form)
      create(:candidate_preference, :anywhere_in_england, application_form:)

      render_inline(described_class.new(application_form:))

      expect(page).to have_content 'The candidate has said they can train anywhere in England.'
    end
  end
end
