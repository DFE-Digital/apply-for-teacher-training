require 'rails_helper'

RSpec.describe CandidateInterface::LocationPreferences do
  let(:preference) { create(:candidate_preference) }
  let(:application_form) do
    create(:application_form, :completed, candidate: preference&.candidate || create(:candidate))
  end
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision, application_form:)
  end

  describe '.add_default_location_preferences' do
    context 'with UK candidate' do
      it 'adds default location preferences' do
        expect { described_class.add_default_location_preferences(preference:) }.to(
          change(preference.location_preferences, :count).by(2),
        )

        expect(preference.location_preferences.first.name).to eq(application_form.postcode)
        expect(preference.location_preferences.last.name).to eq(application_choice.site.postcode)
      end
    end

    context 'with international candidate' do
      let(:application_form) do
        create(
          :application_form,
          :international_address,
          :completed,
          candidate: preference.candidate,
        )
      end

      it 'adds default location preferences only for the choice' do
        expect { described_class.add_default_location_preferences(preference:) }.to(
          change(preference.location_preferences, :count).by(1),
        )

        expect(preference.location_preferences.last.name).to eq(application_choice.site.postcode)
      end
    end
  end

  describe '.add_dynamic_location' do
    context 'when preference is opt in' do
      it 'adds a location preference from application_choice' do
        expect { described_class.add_dynamic_location(preference:, application_choice:) }.to(
          change(preference.location_preferences, :count).by(1),
        )

        expect(preference.location_preferences.last.name).to eq(application_choice.site.postcode)
      end
    end

    context 'when preference is nil' do
      let(:preference) { nil }

      it 'does not add a location preference from application_choice' do
        expect { described_class.add_dynamic_location(preference:, application_choice:) }.to(
          not_change(CandidateLocationPreference, :count),
        )
      end
    end

    context 'when preference is opt out' do
      let(:preference) { create(:candidate_preference, pool_status: 'opt_out') }

      it 'does not add a location preference from application_choice' do
        expect { described_class.add_dynamic_location(preference:, application_choice:) }.to(
          not_change(preference.location_preferences, :count),
        )
      end
    end
  end
end
