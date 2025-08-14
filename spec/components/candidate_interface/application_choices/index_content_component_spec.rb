require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::IndexContentComponent do
  describe '#content_component' do
    it 'returns UpdateLocationAndFundingPreferencesComponent' do
      application_form = build_stubbed(:application_form)

      component = described_class.new(application_form:)

      expect(component.content_component).to be_a(CandidateInterface::MidCycleContentComponent)
    end

    context 'when the application form is after the apply deadline' do
      it 'returns AfterDeadlineContentComponent' do
        application_form = build_stubbed(:application_form)
        allow(application_form).to receive(:after_apply_deadline?).and_return(true)

        component = described_class.new(application_form:)

        expect(component.content_component).to be_a(CandidateInterface::AfterDeadlineContentComponent)
      end
    end

    context 'when the application form is before apply opens, not after the apply deadline' do
      it 'returns CarriedOverContentComponent' do
        application_form = build_stubbed(:application_form)
        allow(application_form).to receive_messages(after_apply_deadline?: false, before_apply_opens?: true)

        component = described_class.new(application_form:)

        expect(component.content_component).to be_a(CandidateInterface::CarriedOverContentComponent)
      end
    end
  end
end
