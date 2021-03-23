require 'rails_helper'

RSpec.describe OfferPathHelper do
  let(:application_choice) { build_stubbed(:application_choice) }

  describe '#offer_path_for' do
    context 'when mode is :new' do
      context 'when :select_option' do
        it 'returns the decision path' do
          expect(helper.offer_path_for(application_choice, 'select_option'))
            .to eq(new_provider_interface_application_choice_decision_path(application_choice, {}))
        end
      end

      context 'when any other step' do
        it 'returns the step based path' do
          expect(helper.offer_path_for(application_choice, :other_step))
            .to eq([:new, :provider_interface, application_choice, :offer, :other_step, {}])
        end
      end
    end

    context 'when mode is :edit' do
      context 'when :offer' do
        it 'returns the offer path' do
          expect(helper.offer_path_for(application_choice, 'offer', :edit))
            .to eq(provider_interface_application_choice_offers_path(application_choice, {}))
        end
      end

      context 'when any other step' do
        it 'returns the step edit path' do
          expect(helper.offer_path_for(application_choice, :other_step, :edit))
            .to eq([:edit, :provider_interface, application_choice, :offer, :other_step, {}])
        end
      end
    end
  end
end
