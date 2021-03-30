require 'rails_helper'

RSpec.describe WizardPathHistory do
  describe '#initialize' do
    context 'when no path_history is set' do
      it 'initializes it to an empty array' do
        service = described_class.new(nil)

        expect(service.path_history).to eq([])
      end
    end
  end

  describe '#update' do
    let(:service) { described_class.new(%i[step1 step2], step: step, action: action) }

    context 'when action is `back`' do
      let(:action) { 'back' }
      let(:step) { nil }

      it 'removes and returns the last item of path_history' do
        service = described_class.new(%i[step1 step2], action: 'back')

        expect(service.update).to eq(:step2)
        expect(service.path_history).to eq([:step1])
      end
    end

    context 'when action is not `back` and step is provided' do
      let(:action) { nil }
      let(:step) { :step3 }

      it 'appends the step to the path_history' do
        service.update

        expect(service.path_history).to eq(%i[step1 step2 step3])
      end
    end
  end

  describe '#previous_step' do
    let(:service) { described_class.new(%i[step1 step2 step3 step2], step: step, action: 'back') }

    context 'when an invalid step is specified' do
      let(:step) { :step }

      it 'raises a NoSuchStepError' do
        expect { service.previous_step }.to raise_error(WizardPathHistory::NoSuchStepError)
      end
    end

    context 'when a step is specified' do
      let(:step) { :step2 }

      it 'returns the latest previous step' do
        expect(service.previous_step).to eq(:step3)
      end
    end

    context 'when no step is specified' do
      let(:step) {}

      it 'returns the step before the last' do
        expect(service.previous_step).to eq(:step3)
      end
    end
  end
end
