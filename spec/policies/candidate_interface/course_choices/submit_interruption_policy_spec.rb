require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::SubmitInterruptionPolicy do
  subject(:policy) { described_class }

  permissions :show? do
    context 'with international_application' do
      it 'permits the user to view the page' do
        application_form = create(:application_form, first_nationality: 'Romanian')

        expect(policy).to permit(application_form.candidate, nil)
      end
    end

    context 'with international qualification' do
      it 'permits the user to view the page' do
        application_form = create(:application_form, first_nationality: 'British')
        create(:application_qualification, international: true, application_form:)

        expect(policy).to permit(application_form.candidate, nil)
      end
    end

    context 'with UK application' do
      it 'does not permit the user to view the page' do
        application_form = create(:application_form, first_nationality: 'British')

        expect(policy).not_to permit(application_form.candidate, nil)
      end
    end
  end
end
