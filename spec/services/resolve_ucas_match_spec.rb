require 'rails_helper'

RSpec.describe ResolveUCASMatch do
  describe '#call' do
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:ucas_match) do
      instance_double(
        UCASMatch,
        ready_to_resolve?: ready_to_resolve,
        duplicate_applications_withdrawn_from_apply?: duplicate_applications_withdrawn,
      )
    end
    let(:ucas_match_retriever) { instance_double(UCASMatches::RetrieveForApplicationChoice, call: ucas_match) }
    let(:ucas_match_resolver) { instance_double(UCASMatches::ResolveOnApply, call: true) }
    let(:ready_to_resolve) { true }
    let(:duplicate_applications_withdrawn) { true }

    before do
      allow(UCASMatches::RetrieveForApplicationChoice).to receive(:new).and_return(ucas_match_retriever)
      allow(UCASMatches::ResolveOnApply).to receive(:new).and_return(ucas_match_resolver)
    end

    it 'retrieves a UCAS Match for the application choice and resolves on apply' do
      described_class.new(application_choice: application_choice).call

      expect(UCASMatches::RetrieveForApplicationChoice).to have_received(:new).with(application_choice)
      expect(ucas_match_retriever).to have_received(:call)

      expect(UCASMatches::ResolveOnApply).to have_received(:new).with(ucas_match)
      expect(ucas_match_resolver).to have_received(:call)
    end

    context 'when the ucas match does not need resolving' do
      let(:ready_to_resolve) { false }

      it 'does not call the resolving service' do
        described_class.new(application_choice: application_choice).call

        expect(ucas_match_resolver).not_to have_received(:call)
      end
    end
  end
end
