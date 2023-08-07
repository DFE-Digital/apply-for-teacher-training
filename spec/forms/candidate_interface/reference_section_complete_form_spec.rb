require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceSectionCompleteForm do
  context 'when two or more references' do
    context 'when mark as incomplete' do
      it 'is valid' do
        application_form = create(:application_form, :with_completed_references)
        create(:reference, email_address: nil, relationship: nil, application_form: application_form)
        form = described_class.new(application_form: application_form, completed: 'false')
        expect(form).to be_valid
      end
    end

    context 'when one of the references has incomplete email' do
      it 'is invalid' do
        application_form = create(:application_form, :with_completed_references)
        create(:reference, application_form: application_form)
        create(:reference, email_address: nil, application_form: application_form)
        form = described_class.new(application_form: application_form, completed: 'true')
        expect(form).not_to be_valid
        expect(form.errors[:application_form]).to include(
          I18n.t('errors.messages.incomplete_references'),
        )
      end
    end

    context 'when one of the references has incomplete relationship' do
      it 'is invalid' do
        application_form = create(:application_form, :with_completed_references)
        create(:reference, application_form: application_form)
        create(:reference, relationship: nil, application_form: application_form)
        form = described_class.new(application_form: application_form, completed: 'true')
        expect(form).not_to be_valid
      end
    end

    context 'when one of the references has wrong data' do
      it 'is invalid' do
        application_form = create(:application_form, :with_completed_references)
        create(:reference, email_address: 'aaa', relationship: nil, application_form: application_form)
        form = described_class.new(application_form: application_form, completed: 'true')
        expect(form).not_to be_valid
      end
    end

    context 'when references has complete data' do
      it 'is valid' do
        application_form = create(:application_form)
        create_list(:reference, 2, application_form: application_form)
        form = described_class.new(application_form: application_form, completed: 'true')
        expect(form).to be_valid
      end
    end
  end
end
