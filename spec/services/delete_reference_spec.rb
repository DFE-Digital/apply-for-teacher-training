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
  let(:reference) { create(:reference, :feedback_provided, application_form: completed_application_form) }

  describe '#call' do
    it 'allows reference to be deleted if the contact details are incomplete' do
      application_choice = completed_application_form.application_choices.first
      CandidateInterface::SubmitApplicationChoice.new(application_choice).call
      reference.update(name: nil)
      described_class.new.call(reference:)

      expect { reference.reload }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find ApplicationReference with/)
    end

    it 'raises error if application has been submitted to providers' do
      application_choice = completed_application_form.application_choices.first
      CandidateInterface::SubmitApplicationChoice.new(application_choice).call
      expect { described_class.new.call(reference:) }.to raise_error('Application has been sent to providers')
    end

    it 'deletes the reference' do
      application_form = create(:application_form)
      reference_to_delete = create(:reference, :feedback_provided, application_form:)
      create(:reference, :feedback_provided, application_form:)

      described_class.new.call(reference: reference_to_delete)

      expect { reference_to_delete.reload }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find ApplicationReference with/)
      expect(application_form.application_references.count).to eq 1
    end

    it 'marks the section as incomplete' do
      application_form = create(:application_form, references_completed: true)
      create_list(:reference, 2, :feedback_provided, selected: true, application_form:)

      described_class.new.call(reference: application_form.application_references.creation_order.first)

      expect(application_form.reload.references_completed).to be false
    end
  end
end
