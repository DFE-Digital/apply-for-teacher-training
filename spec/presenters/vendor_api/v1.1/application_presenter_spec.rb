require 'rails_helper'

RSpec.describe 'ApplicationPresenter' do
  subject(:application_json) { application_presenter.new(version, application_choice).as_json }

  let(:application_presenter) { VendorAPI::ApplicationPresenter }
  let(:version) { '1.1' }
  let(:attributes) { application_json[:attributes] }

  describe 'deferred offer' do
    context 'when an offer has been deferred in the same cycle' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :offer_deferred, current_recruitment_cycle_year: 2022, offer_deferred_at: Date.new(2022, 3, 18))
      end

      it 'returns the correct fields with confirmation of deferral set to the next cycle' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: application_choice.status_before_deferral,
            offer_deferred_at: application_choice.offer_deferred_at.iso8601,
            deferred_to_recruitment_cycle_year: 2023,
          },
        )
      end
    end

    context 'when an offer from the previous cycle has been deferred in the current cycle' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :offer_deferred, current_recruitment_cycle_year: 2021, offer_deferred_at: Date.new(2022, 1, 18))
      end

      it 'returns the correct fields with confirmation of deferral set to the current cycle' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: application_choice.status_before_deferral,
            offer_deferred_at: application_choice.offer_deferred_at.iso8601,
            deferred_to_recruitment_cycle_year: 2022,
          },
        )
      end
    end

    context 'when an offer has been deferred multiple times' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :offer_deferred, current_recruitment_cycle_year: 2021, offer_deferred_at: Date.new(2021, 1, 18))
      end

      it 'returns the correct fields with confirmation of deferral set to the next cycle' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: application_choice.status_before_deferral,
            offer_deferred_at: application_choice.offer_deferred_at.iso8601,
            deferred_to_recruitment_cycle_year: 2022,
          },
        )
      end
    end

    context 'when the application is not in the offer state yet' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :awaiting_provider_decision)
      end

      it 'returns nil' do
        expect(attributes[:offer]).to be_nil
      end
    end

    context 'when the application has not been deferred' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :offered)
      end

      it 'returns the deferred fields with a nil value' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: nil,
            offer_deferred_at: nil,
            deferred_to_recruitment_cycle_year: nil,
          },
        )
      end
    end
  end

  describe 'interviews section' do
    let!(:application_choice) do
      create(
        :application_choice,
        :with_completed_application_form,
        :interviewing,
      )
    end

    before do
      create(:interview, :cancelled, application_choice:)
      application_choice.reload
    end

    it 'includes an interviews section' do
      expect(attributes[:interviews]).to be_present
    end

    it 'returns all interviews, including cancelled' do
      expect(attributes[:interviews].count).to eq(2)
    end

    it 'sorts interviews in descending updated_at order' do
      ordered = application_choice.interviews.order(updated_at: :desc).all
      expected = ordered.map(&:id)

      observed = attributes[:interviews].map { |interview| interview[:id].to_i }
      expect(observed).to eq(expected)
    end
  end

  describe 'notes' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, :with_completed_application_form) }

    it 'returns notes for the application' do
      note1 = create(:note, application_choice:)
      TestSuiteTimeMachine.advance
      note2 = create(:note, application_choice:)

      expect(attributes[:notes]).to eq([
        {
          id: note2.id.to_s,
          author: note2.user.full_name,
          message: note2.message,
          created_at: note2.created_at.iso8601,
          updated_at: note2.updated_at.iso8601,
        },
        {
          id: note1.id.to_s,
          author: note1.user.full_name,
          message: note1.message,
          created_at: note1.created_at.iso8601,
          updated_at: note1.updated_at.iso8601,
        },
      ])
    end
  end

  describe 'withdraw' do
    let(:application_choice) { create(:application_choice, :withdrawn_at_candidates_request, :with_completed_application_form) }

    it 'returns the fields related to a withdrawn or declined application' do
      expect(attributes).to include(
        {
          withdrawn_or_declined_for_candidate: true,
        },
      )
    end
  end
end
