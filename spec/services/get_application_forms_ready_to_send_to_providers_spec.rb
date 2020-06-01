require 'rails_helper'

RSpec.describe GetApplicationFormsReadyToSendToProviders do
  subject(:returned_application_forms) { GetApplicationFormsReadyToSendToProviders.call }

  let(:application_form) { create(:application_form, edit_by: 1.day.ago) }

  context 'when the edit_by dates have passed and the application_choices are application_complete' do
    before do
      create(:application_choice, application_form: application_form, status: :application_complete)
      create(:application_choice, application_form: application_form, status: :application_complete)
    end

    it 'returns the form' do
      expect(returned_application_forms.first).to eq application_form
    end
  end

  context 'when the edit_by dates have not passed and the application_choices are application_complete' do
    let(:application_form) { create(:application_form, edit_by: 1.day.from_now) }

    before do
      create(:application_choice, application_form: application_form, status: :application_complete)
      create(:application_choice, application_form: application_form, status: :application_complete)
    end

    it 'does not return the form' do
      expect(returned_application_forms).to be_empty
    end
  end

  context 'when the edit_by dates have passed and the application_choices are not application_complete' do
    let(:application_form) { create(:application_form, edit_by: 1.day.from_now) }

    before do
      create(:application_choice, application_form: application_form, status: :awaiting_references)
      create(:application_choice, application_form: application_form, status: :awaiting_references)
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
      create(:application_choice, application_form: application_form, status: :awaiting_references)
      create(:application_choice, application_form: application_form, status: :application_complete)
    end

    it 'does not return the form' do
      expect(returned_application_forms).to be_empty
    end
  end

  context 'when there are multiple application choices' do
    before do
      create(:application_choice, application_form: application_form, status: :application_complete)
      create(:application_choice, application_form: application_form, status: :application_complete)
    end

    it 'returns only one form' do
      expect(returned_application_forms.count).to eq 1
    end
  end
end
