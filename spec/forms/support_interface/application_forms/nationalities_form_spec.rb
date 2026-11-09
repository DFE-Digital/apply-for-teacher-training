require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::NationalitiesForm, :with_audited, type: :model do
  describe '#save' do
    context 'when the application is from a previous cycle' do
      let(:application_form) do
        create(
          :completed_application_form,
          recruitment_cycle_year: previous_year,
          application_choices_count: 1,
        )
      end

      before { RequestStore.store[:allow_unsafe_application_choice_touches] = false }

      it 'updates the nationalities' do
        form = described_class.new(
          british: 'British',
          audit_comment: 'https://becomingateacher.zendesk.com/agent/tickets/12345',
        )

        expect(form.save(application_form)).to be(true)
        expect(application_form.reload.first_nationality).to eq('British')
      end
    end
  end
end
