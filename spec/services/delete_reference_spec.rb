require 'rails_helper'

RSpec.describe DeleteReference do
  let(:completed_application_form) do
    create(
      :completed_application_form,
      application_choices_count: 3,
      work_experiences_count: 2,
      volunteering_experiences_count: 2,
      references_count: 2,
      full_work_history: true,
    )
  end
  let(:status) { :not_requested_yet }
  let(:reference) { create(:reference, status, application_form: completed_application_form) }

  describe '#call' do
    context 'when the reference has not been requested yet' do
      it 'allows reference to be deleted' do
        application_form = create(:application_form)
        reference_to_delete = create(:reference, :not_requested_yet, application_form:)
        create(:reference, :feedback_provided, application_form:)

        described_class.new.call(reference: reference_to_delete)

        expect { reference_to_delete.reload }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find ApplicationReference with/)
        expect(application_form.application_references.count).to eq 1
      end
    end

    context 'when the reference has been requested' do
      let(:status) { :feedback_provided }

      it 'raises an error before the reference feedback has been requested' do
        application_choice = completed_application_form.application_choices.first
        CandidateInterface::SubmitApplicationChoice.new(application_choice).call
        expect { described_class.new.call(reference:) }.to raise_error('Reference feedback has been requested')
      end
    end

    it 'marks the section as incomplete' do
      application_form = create(:application_form, references_completed: true)
      create_list(:reference, 2, :not_requested_yet, selected: true, application_form:)

      described_class.new.call(reference: application_form.application_references.creation_order.first)

      expect(application_form.reload.references_completed).to be false
    end
  end
end
