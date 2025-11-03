require 'rails_helper'

RSpec.describe 'ApplicationPresenter' do
  let(:application_presenter) { VendorAPI::ApplicationPresenter }
  let(:version) { '1.3' }
  let(:application_json) { application_presenter.new(version, application_choice).as_json }
  let(:attributes) { application_json[:attributes] }
  let(:application_form) { application_choice.application_form }

  describe '#references' do
    let(:reference) do
      build(:reference, reference_status)
    end

    let(:reference_status) { :feedback_provided }

    before do
      application_form.application_references.destroy_all
      application_form.application_references << reference
    end

    context 'when accepted offer' do
      let(:application_choice) do
        create(:application_choice, :accepted)
      end

      it 'returns references' do
        expect(
          attributes[:references].map { |reference| reference[:id] },
        ).to include(reference.id)
      end

      context 'when reference is feedback_provided' do
        let(:reference_status) { :feedback_provided }

        it 'returns the correct reference status' do
          expect(attributes[:references].first[:reference_received]).to be(true)
        end
      end

      context 'when reference some other state' do
        let(:reference_status) { :feedback_refused }

        it 'always returns false as the reference status' do
          expect(attributes[:references]).to eq([])
        end
      end
    end

    context 'when pre offer' do
      let(:application_choice) do
        create(:application_choice, :offered)
      end

      it 'returns references' do
        expect(
          attributes[:references].map { |reference| reference[:id] },
        ).to include(reference.id)
      end

      it 'always returns false as the reference status' do
        reference.update!(feedback_status: :feedback_requested)
        expect(application_json.dig(:attributes, :references, 0, :reference_received)).to be(false)
        reference.update!(feedback_status: :feedback_provided)
        expect(application_json.dig(:attributes, :references, 0, :reference_received)).to be(false)
      end
    end

    context 'when offer is withdrawn' do
      let(:application_choice) do
        create(:application_choice, :offer_withdrawn)
      end

      it 'returns no references' do
        expect(attributes[:references]).to be_empty
      end
    end

    context 'when offer is declined' do
      let(:application_choice) do
        create(:application_choice, :declined)
      end

      it 'returns no references' do
        expect(attributes[:references]).to be_empty
      end
    end

    context 'when the application is withdrawn' do
      let(:application_choice) do
        create(:application_choice, :withdrawn)
      end

      it 'returns no references' do
        expect(attributes[:references]).to be_empty
      end
    end

    context 'when the application is rejected' do
      let(:application_choice) do
        create(:application_choice, :rejected)
      end

      it 'returns no references' do
        expect(attributes[:references]).to be_empty
      end
    end

    context 'when the offer conditions are not met' do
      let(:application_choice) do
        create(:application_choice, :conditions_not_met)
      end

      it 'returns references' do
        expect(attributes[:references]).not_to be_empty
      end
    end
  end
end
