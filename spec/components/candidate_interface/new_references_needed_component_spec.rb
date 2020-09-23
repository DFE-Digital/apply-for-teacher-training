require 'rails_helper'

RSpec.describe CandidateInterface::NewReferencesNeededComponent do
  describe '#render?' do
    let(:application_form) { create(:completed_application_form) }

    context 'when an application form needs more references' do
      it 'renders the component' do
        allow(CandidateInterface::EndOfCyclePolicy).to receive(:can_add_course_choice?).and_return(true)
        create(:reference, :requested, application_form: application_form, requested_at: Time.zone.now - 30.days)

        expect(described_class.new(application_form: application_form).render?).to be_truthy
      end
    end

    context "when we're at the end of the cycle" do
      it 'does not render the component' do
        allow(CandidateInterface::EndOfCyclePolicy).to receive(:can_add_course_choice?).and_return(false)
        create(:reference, :requested, application_form: application_form, requested_at: Time.zone.now - 30.days)

        expect(described_class.new(application_form: application_form).render?).to be_falsey
      end
    end
  end
end
