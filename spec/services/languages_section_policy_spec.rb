require 'rails_helper'

RSpec.describe LanguagesSectionPolicy do
  describe '#hide?' do
    context 'when efl_section feature flag is active' do
      before { FeatureFlag.activate :efl_section }

      context 'and english_main_language has not been filled' do
        let(:application_form) { application_form_where_english_main_language_is_nil }

        it 'returns true' do
          expect(described_class.hide?(application_form)).to eq true
        end
      end

      context 'and english_main_language has been filled' do
        let(:application_form) { build(:application_form, english_main_language: true) }

        it 'returns false' do
          expect(described_class.hide?(application_form)).to eq false
        end
      end
    end

    context 'when efl_section feature flag is inactive' do
      before { FeatureFlag.deactivate :efl_section }

      # An application state which would return true if the flag were active
      let(:application_form) { application_form_where_english_main_language_is_nil }

      it 'returns false' do
        expect(described_class.hide?(application_form)).to eq false
      end
    end

    def application_form_where_english_main_language_is_nil
      application_choice = build(:application_choice, :awaiting_references)
      build(
        :completed_application_form,
        english_main_language: nil,
        application_choices: [application_choice],
      )
    end
  end
end
