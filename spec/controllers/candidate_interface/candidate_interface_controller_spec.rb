require 'rails_helper'

RSpec.describe CandidateInterface::CandidateInterfaceController do
  before do
    allow(instance).to receive(:current_candidate).and_return(candidate)
  end

  let(:instance) { described_class.new }
  let(:candidate) { create(:candidate) }

  describe '.active_previous_application' do
    subject(:active_previous_application) { instance.active_previous_application }

    let(:current_application_form) { create(:application_form, candidate: candidate) }
    let(:previous_application_form) do
      create(
        :application_form,
        candidate: candidate,
        created_at: current_application_form.created_at - 1.year,
        recruitment_cycle_year: current_application_form.recruitment_cycle_year - 1,
      )
    end

    before do
      current_application_form
      previous_application_form
      previous_application_choice
    end

    context 'when the candidate has an previous application form, with a january application choice with an "in progress" status' do
      let(:jan_course) { create(:course, start_date: "01/01/#{current_application_form.recruitment_cycle_year}") }
      let(:jan_course_option) { create(:course_option, course: jan_course) }
      let(:previous_application_choice) do
        create(
          :application_choice,
          application_form: previous_application_form,
          current_recruitment_cycle_year: previous_application_form.recruitment_cycle_year,
          course_option: jan_course_option,
          status: :awaiting_provider_decision,
        )
      end

      it 'returns the previous application form' do
        expect(instance.active_previous_application).to eq(previous_application_form)
      end
    end

    context 'when the candidate has an previous application form, with an application choice not with an "in progress" status' do
      let(:previous_application_choice) do
        create(:application_choice, application_form: previous_application_form, status: :rejected)
      end

      it 'returns nil' do
        expect(instance.active_previous_application).to be_nil
      end
    end
  end

  describe '.active_application_choices' do
    subject(:active_previous_application) { instance.active_application_choices }

    let(:current_application_form) { create(:application_form, candidate: candidate) }
    let(:previous_application_form) do
      create(
        :application_form,
        candidate: candidate,
        created_at: current_application_form.created_at - 1.year,
        recruitment_cycle_year: current_application_form.recruitment_cycle_year - 1,
      )
    end
    let(:current_application_choice) { create(:application_choice, application_form: current_application_form) }

    before do
      current_application_choice
      previous_application_choice
    end

    context 'when the candidate has an previous application form, with an application choice with an "in progress" status' do
      let(:jan_course) { create(:course, start_date: "01/01/#{current_application_form.recruitment_cycle_year}") }
      let(:jan_course_option) { create(:course_option, course: jan_course) }
      let(:previous_application_choice) do
        create(
          :application_choice,
          application_form: previous_application_form,
          current_recruitment_cycle_year: previous_application_form.recruitment_cycle_year,
          course_option: jan_course_option,
          status: :awaiting_provider_decision,
        )
      end

      it 'returns application choices for both the current application form and previous application form' do
        expect(active_previous_application).to contain_exactly(current_application_choice, previous_application_choice)
      end
    end

    context 'when the candidate has an previous application form, not with an application choice with an "in progress" status' do
      let(:jan_course) { create(:course, start_date: "01/01/#{current_application_form.recruitment_cycle_year}") }
      let(:jan_course_option) { create(:course_option, course: jan_course) }
      let(:previous_application_choice) do
        create(
          :application_choice,
          application_form: previous_application_form,
          current_recruitment_cycle_year: previous_application_form.recruitment_cycle_year,
          course_option: jan_course_option,
          status: :rejected,
        )
      end

      it 'returns application choices for both the current application form and previous application form' do
        expect(active_previous_application).to contain_exactly(current_application_choice)
      end
    end
  end
end
