require 'rails_helper'

RSpec.describe CandidateInterface::DeleteApplicationChoice do
  describe '#call' do
    context 'when an application form has only one application choice' do
      it 'deletes the given application choice and resets `course_choices_completed`' do
        application_form = create(:application_form, course_choices_completed: true)
        application_choice = create(:application_choice, application_form: application_form)

        described_class.new(application_choice: application_choice).call
        expect(application_form.reload.application_choices).to be_empty
        expect(application_form.course_choices_completed).to be_nil
      end
    end

    context 'when an application form has multiple application choices' do
      it 'deletes the only the given application choice and leaves `course_choices_completed` as true' do
        application_form = create(:application_form, course_choices_completed: true)
        create(:application_choice, application_form: application_form)
        application_choice = create(:application_choice, application_form: application_form)

        described_class.new(application_choice: application_choice).call
        expect(application_choice.destroyed?).to be(true)
        expect(application_form.reload.application_choices.count).to be(1)
        expect(application_form.course_choices_completed).to be(true)
      end
    end
  end
end
