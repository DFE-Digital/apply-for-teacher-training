require 'rails_helper'

RSpec.describe CandidateInterface::EditableSectionWarning do
  subject(:result) do
    render_inline(
      described_class.new(current_application:, section_policy:),
    )
  end

  context 'when candidate has submitted applications' do
    let(:current_application) { create(:application_form, :completed, submitted_application_choices_count: 1) }

    context 'when candidate can edit the section' do
      let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: true, personal_statement?: false, work_history?: false) }

      it 'renders message' do
        expect(result.text).to include(
          'Your open applications will be updated with any changes you make in this section.',
        )
      end

      context 'when the candidate can edit the section and it is the personal statement' do
        let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: true, personal_statement?: true) }

        it 'renders message' do
          expect(result.text).to include(
            'Changes you make in this section will only be included in future applications. Your open applications will not be updated.',
          )
        end
      end

      context 'when the candidate can edit the section and it is the work_history' do
        let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: true, personal_statement?: false, work_history?: true) }

        it 'renders message' do
          expect(result.text).to include(
            'Changes you make in this section will only be included in future applications. Your open applications will not be updated.',
          )
        end
      end

      context 'when the candidate has an active previous application' do
        let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: true, personal_statement?: false, work_history?: false) }

        let(:previous_application_form) do
          create(
            :completed_application_form,
            recruitment_cycle_year: current_application.recruitment_cycle_year.pred,
            candidate: current_application.candidate,
            created_at: current_application.created_at - 1.year,
          )
        end
        let(:jan_course) do
          create(
            :course,
            start_date: "01/01/#{current_application.recruitment_cycle_year}",
            recruitment_cycle_year: previous_application_form.recruitment_cycle_year,
          )
        end
        let(:previous_application_choice) do
          create(
            :application_choice,
            :awaiting_provider_decision,
            application_form: previous_application_form,
            course_option: create(:course_option, course: jan_course),
          )
        end

        before { previous_application_choice }

        it 'renders message' do
          expect(result.text).to include(
            "Changes you make in this section will update your open applications for the #{current_application.academic_year_range_name} academic year. " \
            "Your open applications for the #{previous_application_form.academic_year_range_name} academic year will not be updated.",
          )
        end
      end
    end

    context 'when candidate can not edit the section' do
      let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: false, personal_statement?: false) }

      it 'renders nothing' do
        expect(result.text).to be_blank
      end
    end
  end

  context 'when candidate did not submitted yet' do
    let(:section_policy) { instance_double(CandidateInterface::SectionPolicy, can_edit?: true, personal_statement?: false) }
    let(:current_application) { create(:application_form) }

    it 'renders nothing' do
      expect(result.text).to be_blank
    end
  end
end
