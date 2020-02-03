require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceFeedbackForm do
  describe '#save' do
    it 'invokes the ReceiveReference class if input is valid' do
      application_form = FactoryBot.create(:completed_application_form, references_count: 0)
      application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references', edit_by: 1.day.from_now) }
      unsubmitted_reference = build(:reference, :unsubmitted)
      application_form.application_references << unsubmitted_reference
      allow(ReceiveReference).to receive(:new).and_return(instance_double(ReceiveReference, save!: true))

      described_class.new(
        reference: unsubmitted_reference,
        feedback: 'A reference',
      ).save

      expect(ReceiveReference).to have_received(:new)
    end

    it 'does not invoke the ReceiveReference class if input is invalid' do
      application_form = FactoryBot.create(:completed_application_form, references_count: 0)
      application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
      unsubmitted_reference = build(:reference, :unsubmitted)
      application_form.application_references << unsubmitted_reference
      allow(ReceiveReference).to receive(:new).and_return(instance_double(ReceiveReference, save!: true))

      described_class.new(
        reference: unsubmitted_reference,
        feedback: '',
      ).save

      expect(ReceiveReference).not_to have_received(:new)
    end
  end
end
