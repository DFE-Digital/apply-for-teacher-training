require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::EditDegreeForm, :with_audited, type: :model do
  describe '#save!' do
    context 'when the application is from a previous cycle' do
      let(:application_form) do
        create(
          :completed_application_form,
          recruitment_cycle_year: previous_year,
          application_choices_count: 1,
        )
      end
      let(:degree) { create(:degree_qualification, application_form:) }

      before do
        degree
        RequestStore.store[:allow_unsafe_application_choice_touches] = false
      end

      it 'updates the degree' do
        form = described_class.new(degree)
        form.assign_attributes(
          start_year: '2015',
          award_year: '2018',
          audit_comment: 'https://becomingateacher.zendesk.com/agent/tickets/12345',
        )

        form.save!

        expect(degree.reload).to have_attributes(start_year: '2015', award_year: '2018')
      end
    end
  end
end
