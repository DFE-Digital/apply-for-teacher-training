require 'rails_helper'

RSpec.describe GetApplicationFormsReadyToSendToProviders do
  subject(:returned_application_forms) { GetApplicationFormsReadyToSendToProviders.call }

  let(:application_form) { create(:application_form) }

  context 'when the edit_by dates have passed and the application_choices are application_complete' do
    before do
      create(:application_choice, application_form: application_form, status: :application_complete, edit_by: 1.day.ago)
      create(:application_choice, application_form: application_form, status: :application_complete, edit_by: 1.day.ago)
    end

    it 'returns the form' do
      expect(returned_application_forms.first).to eq application_form
    end
  end

  context 'when the edit_by dates have not passed and the application_choices are application_complete' do
    before do
      create(:application_choice, application_form: application_form, status: :application_complete, edit_by: 1.day.from_now)
      create(:application_choice, application_form: application_form, status: :application_complete, edit_by: 1.day.from_now)
    end

    it 'does not return the form' do
      expect(returned_application_forms).to be_empty
    end
  end

  context 'when the edit_by dates have passed and the application_choices are not application_complete' do
    before do
      create(:application_choice, application_form: application_form, status: :awaiting_references, edit_by: 1.day.from_now)
      create(:application_choice, application_form: application_form, status: :awaiting_references, edit_by: 1.day.from_now)
    end

    it 'does not return the form' do
      expect(returned_application_forms).to be_empty
    end
  end

  context 'when the application_choices have a mixture of statuses' do
    before do
      # this should never happen. it is a possibility, though, because
      # the fact that references have been received is currently sprinkled
      # across all three application choices. this needs looking at.
      create(:application_choice, application_form: application_form, status: :awaiting_references, edit_by: 1.day.ago)
      create(:application_choice, application_form: application_form, status: :application_complete, edit_by: 1.day.ago)
    end

    it 'does not return the form' do
      expect(returned_application_forms).to be_empty
    end
  end
end
