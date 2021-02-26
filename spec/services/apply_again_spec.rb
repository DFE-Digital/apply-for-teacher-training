require 'rails_helper'
require 'services/duplicate_application_shared_examples'

RSpec.describe ApplyAgain do
  def original_application_form
    Timecop.travel(-1.day) do
      @original_application_form ||= create(
        :completed_application_form,
        :with_gcses,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        full_work_history: true,
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @original_application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: @original_application_form)
      create(:application_choice, :with_rejection, application_form: @original_application_form)
    end
    @original_application_form
  end

  it_behaves_like 'duplicates application form', 'apply_2', RecruitmentCycle.current_year

  describe '#call' do
    context 'application_form.ended_without_success? returns true' do
      it 'calls the DuplicateApplication service' do
        application = instance_double(ApplicationForm, ended_without_success?: true)
        duplication_service = instance_double(DuplicateApplication, duplicate: true)
        allow(DuplicateApplication).to receive(:new)
          .with(application, target_phase: 'apply_2')
          .and_return(duplication_service)

        described_class.new(application).call

        expect(duplication_service).to have_received(:duplicate)
      end
    end

    context 'application_form.ended_without_success? returns false' do
      it 'returns false' do
        application = instance_double(ApplicationForm, ended_without_success?: false)

        expect(described_class.new(application).call).to eq false
      end
    end
  end
end
