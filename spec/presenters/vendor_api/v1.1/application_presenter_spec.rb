require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  subject(:application_json) { described_class.new(version, application_choice).as_json }

  let(:version) { '1.1' }
  let(:attributes) { application_json[:attributes] }

  describe 'deferred offer' do
    context 'when the offer has been deferred' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :with_deferred_offer)
      end

      it 'returns the fields related to deferring an offer' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: application_choice.status_before_deferral,
            offer_deferred_at: application_choice.offer_deferred_at.iso8601,
          },
        )
      end
    end

    context 'when the application is not in the offer state yet' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :awaiting_provider_decision)
      end

      it 'returns nil' do
        expect(attributes[:offer]).to eq(nil)
      end
    end

    context 'when the application has not been deferred' do
      let(:application_choice) do
        build_stubbed(:application_choice, :with_completed_application_form, :with_offer)
      end

      it 'returns the deferred fields with a nil value' do
        expect(attributes[:offer]).to include(
          {
            status_before_deferral: nil,
            offer_deferred_at: nil,
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
        :with_cancelled_interview,
        :with_scheduled_interview,
      )
    end

    it 'includes an interviews section' do
      expect(attributes[:interviews]).to be_present
    end

    it 'returns all interviews, including cancelled' do
      expect(attributes[:interviews].count).to eq(2)
    end

    it 'sorts interviews in descending updated_at order' do
      ordered = application_choice.interviews.order('updated_at DESC').all
      expected = ordered.map(&:id)

      observed = attributes[:interviews].map { |interview| interview[:id].to_i }
      expect(observed).to eq(expected)
    end
  end

  describe 'notes' do
    let!(:application_choice) { create(:submitted_application_choice, :with_completed_application_form) }
    let!(:note1) { create(:note, application_choice: application_choice) }
    let!(:note2) { create(:note, application_choice: application_choice) }

    it 'returns notes for the application' do
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
end
