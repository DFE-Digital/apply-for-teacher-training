require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceFeedbackForm do
  describe '#save' do
    it 'progresses the application choices to the "application complete" status once all references have been received' do
      application_form = FactoryBot.create(:completed_application_form, references_count: 0)
      application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references', edit_by: 1.day.from_now) }
      unsubmitted_reference = build(:reference, :unsubmitted)
      application_form.application_references << unsubmitted_reference
      application_form.application_references << build(:reference, :complete)

      action = described_class.new(
        reference: unsubmitted_reference,
        feedback: 'A reference',
      )

      action.save

      expect(application_form.reload).to be_application_references_complete
      expect(application_form.application_choices).to all(be_application_complete)
    end

    it 'does not progress the application choices to the "application complete" status without minimum number of references' do
      application_form = FactoryBot.create(:completed_application_form, references_count: 0)
      application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references') }
      unsubmitted_reference = build(:reference, :unsubmitted)
      application_form.application_references << unsubmitted_reference

      action = described_class.new(
        reference: unsubmitted_reference,
        feedback: 'A reference',
      )

      action.save

      expect(application_form).not_to be_application_references_complete
      expect(application_form.application_choices).to all(be_awaiting_references)
    end

    it 'progresses the application choices to the "awaiting_provider_decision" status once all references have been received if edit_by expired' do
      application_form = FactoryBot.create(:completed_application_form, references_count: 0)
      application_form.application_choices.each { |choice| choice.update(status: 'awaiting_references', edit_by: 1.day.ago) }
      unsubmitted_reference = build(:reference, :unsubmitted)
      application_form.application_references << unsubmitted_reference
      application_form.application_references << build(:reference, :complete)

      action = described_class.new(
        reference: unsubmitted_reference,
        feedback: 'A reference',
      )

      action.save

      expect(application_form.reload).to be_application_references_complete
      expect(application_form.application_choices).to all(be_awaiting_provider_decision)
    end
  end
end
