require 'rails_helper'
require 'services/duplicate_application_shared_examples'

RSpec.describe CarryOverApplication do
  def original_application_form
    @original_application_form ||= Timecop.travel(-1.day) do
      application_form = create(
        :completed_application_form,
        application_choices_count: 1,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        with_gces: true,
        full_work_history: true,
      )
      create(:reference, feedback_status: :feedback_provided, application_form: application_form)
      create(:reference, feedback_status: :not_requested_yet, application_form: application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: application_form)
      application_form
    end
  end

  context 'when original application is from an earlier recruitment cycle' do
    before do
      original_application_form.application_choices.first.course.update(
        recruitment_cycle_year: Time.zone.today.year - 1,
      )
    end

    it_behaves_like 'duplicates application form', 'apply_1'
  end

  context 'when original application is from the current recruitment cycle' do
    it 'raises an error' do
      expect { described_class.new(original_application_form).call }.to raise_error(ArgumentError)
    end
  end
end
