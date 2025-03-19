require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditReferenceFeedbackForm do
  subject { described_class.new }

  let(:reference) { create(:reference, feedback: 'Some feedback') }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:feedback) }
    it { is_expected.to validate_presence_of(:audit_comment) }
    it { is_expected.to validate_presence_of(:send_emails) }
  end

  describe '.build_from_reference' do
    it 'initializes the form with feedback from the reference' do
      form = described_class.build_from_reference(reference)

      expect(form.feedback).to eq('Some feedback')
    end
  end

  describe '#save' do
    subject(:form) { described_class.new(valid_attributes) }

    let(:valid_attributes) do
      {
        feedback: 'Updated feedback',
        audit_comment: 'Audit comment',
        send_emails: true,
      }
    end

    context 'when from this cycle' do
      it 'updates the reference with the provided attributes' do
        form.save(reference)
        expect(reference.reload.feedback).to eq('Updated feedback')
      end
    end

    context 'when from old cycle' do
      let(:application_form) do
        create(
          :application_form,
          :with_accepted_offer,
          recruitment_cycle_year: CycleTimetable.previous_year,
        )
      end
      let(:reference) do
        ApplicationForm.with_unsafe_application_choice_touches do
          create(:reference, :feedback_requested, application_form:)
        end
      end

      before do
        RequestStore.store[:allow_unsafe_application_choice_touches] = false
      end

      it 'updates the reference with the provided attributes' do
        form.save(reference)
        expect(reference.reload.feedback).to eq('Updated feedback')
      end
    end
  end
end
