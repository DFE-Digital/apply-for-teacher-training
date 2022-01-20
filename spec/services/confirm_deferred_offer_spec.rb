require 'rails_helper'

RSpec.describe ConfirmDeferredOffer do
  subject(:service) do
    described_class.new(actor: actor,
                        application_choice: application_choice,
                        course_option: course_option,
                        conditions_met: conditions_met)
  end

  let(:application_choice) { build(:application_choice) }
  let(:actor) { build(:provider) }
  let(:course_option) { build(:course_option) }
  let(:conditions_met) { true }

  context 'when conditions_met is set to true' do
    let(:stubbed_service) { instance_double(ReinstateConditionsMet, save!: nil) }
    let(:conditions_met) { true }

    it 'calls the ReinstateConditionsMet service' do
      allow(ReinstateConditionsMet).to receive(:new).and_return(stubbed_service)

      service.save!

      expect(ReinstateConditionsMet).to have_received(:new)
    end
  end

  context 'when conditions_met is set to false' do
    let(:stubbed_service) { instance_double(ReinstatePendingConditions, save!: nil) }
    let(:conditions_met) { false }

    it 'calls the ReinstatePendingConditions service' do
      allow(ReinstatePendingConditions).to receive(:new).and_return(stubbed_service)

      service.save!
      expect(ReinstatePendingConditions).to have_received(:new)
    end
  end

  context 'when save is called' do
    context 'when errors are raised' do
      it 'returns false' do
        expect(service.save).to be false
      end
    end

    context 'when no errors are raised' do
      let(:stubbed_service) { instance_double(ReinstatePendingConditions, save!: nil) }
      let(:conditions_met) { false }

      it 'returns true' do
        allow(ReinstatePendingConditions).to receive(:new).and_return(stubbed_service)

        expect(service.save).to be true
      end
    end
  end
end
