require 'rails_helper'
require 'services/duplicate_application_shared_examples'

RSpec.describe CarryOverApplication do
  before { allow(RecruitmentCycle).to receive(:current_year).and_return(2021) }

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
      original_application_form.update(recruitment_cycle_year: 2020)
    end

    it_behaves_like 'duplicates application form', 'apply_1', 2021
  end

  context 'when original application is from the current open recruitment cycle' do
    before do
      allow(RecruitmentCycle).to receive(:current_year).and_return(2020)
      original_application_form.update(
        recruitment_cycle_year: 2020,
      )
    end

    it 'raises an error' do
      Timecop.freeze(Time.zone.local(2020, 8, 1, 12, 0, 0)) do
        expect { described_class.new(original_application_form).call }.to raise_error(ArgumentError)
      end
    end
  end

  context 'when original application is from the current recruitment cycle but that cycle has now closed' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 9, 19, 12, 0, 0)) do
        example.run
      end
    end

    it_behaves_like 'duplicates application form', 'apply_1', 2021
  end
end
