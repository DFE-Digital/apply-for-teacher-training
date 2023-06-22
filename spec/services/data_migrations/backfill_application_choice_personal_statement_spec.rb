require 'rails_helper'

RSpec.describe DataMigrations::BackfillApplicationChoicePersonalStatement do
  describe '#change' do
    context 'two application forms with different becoming_a_teacher values' do
      it 'sets the personal statement to the becoming a teacher for each form' do
        form_1_choice = create(:application_choice)
        create(:application_form,
               becoming_a_teacher: 'Form 1',
               application_choices: [form_1_choice])

        form_2_choice = create(:application_choice)
        create(:application_form,
               becoming_a_teacher: 'Form 2',
               application_choices: [form_2_choice])

        form_3_choice = create(:application_choice)
        create(:application_form,
               application_choices: [form_3_choice])

        expect { described_class.new.change }
          .to change { form_1_choice.reload.personal_statement }.to('Form 1')
          .and change { form_2_choice.reload.personal_statement }.to('Form 2')
          .and(not_change { form_3_choice.reload.personal_statement })
      end
    end
  end
end
