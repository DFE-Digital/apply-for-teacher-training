require 'rails_helper'

RSpec.describe CandidateInterface::CarryOverPublishedPreference do
  describe '#call' do
    it 'carries over published preferences that have been updated in the new cycle' do
      candidate = create(:candidate)
      application_form_2025 = create(
        :application_form,
        :completed,
        candidate:,
        recruitment_cycle_year: 2025,
        submitted_application_choices_count: 1,
      )
      application_form_2026 = create(
        :application_form,
        :completed,
        candidate:,
        recruitment_cycle_year: 2026,
        submitted_application_choices_count: 1,
      )
      preference_2025 = create(
        :candidate_preference,
        :specific_locations,
        updated_at: 2.days.from_now,
        application_form: application_form_2025,
      )
      create(
        :candidate_location_preference,
        :manchester,
        candidate_preference: preference_2025,
      )
      create(
        :candidate_location_preference,
        :liverpool,
        candidate_preference: preference_2025,
      )
      another_application_form = create(
        :application_form,
        :completed,
        submitted_application_choices_count: 1,
      )
      existing_preference = create(
        :candidate_preference,
        :specific_locations,
        updated_at: 2.days.from_now,
        application_form: another_application_form,
      )

      expect {
        described_class.new.call
      }.to change { application_form_2026.reload.published_preferences.count }.from(0).to(1)
      expect(application_form_2026.published_preference)
        .to have_attributes(
          status: 'published',
          pool_status: 'opt_in',
          training_locations: 'specific',
        )
      expect(application_form_2026.published_preference.location_preferences.pluck(:name))
        .to contain_exactly('Manchester', 'Liverpool')
      expect(another_application_form.reload.published_preference).to eq(existing_preference)
    end

    context 'when application_choice was submitted after published preference' do
      it 'does not carry over the published_preference' do
        candidate = create(:candidate)
        application_form_2025 = create(
          :application_form,
          :completed,
          candidate:,
          recruitment_cycle_year: 2025,
          submitted_application_choices_count: 1,
        )
        application_form_2026 = create(
          :application_form,
          :completed,
          candidate:,
          recruitment_cycle_year: 2026,
          submitted_application_choices_count: 1,
        )
        _preference_2025 = create(
          :candidate_preference,
          :specific_locations,
          updated_at: 2.days.ago,
          application_form: application_form_2025,
        )

        expect {
          described_class.new.call
        }.not_to change(application_form_2026.reload.published_preferences, :count)
      end
    end

    context 'when published preference was opt out' do
      it 'does not carry over the published_preference' do
        candidate = create(:candidate)
        application_form_2025 = create(
          :application_form,
          :completed,
          candidate:,
          recruitment_cycle_year: 2025,
          submitted_application_choices_count: 1,
        )
        application_form_2026 = create(
          :application_form,
          :completed,
          candidate:,
          recruitment_cycle_year: 2026,
          submitted_application_choices_count: 1,
        )
        _preference_2025 = create(
          :candidate_preference,
          :opt_out,
          updated_at: 2.days.from_now,
          application_form: application_form_2025,
        )

        expect {
          described_class.new.call
        }.not_to change(application_form_2026.reload.published_preferences, :count)
      end
    end
  end
end
