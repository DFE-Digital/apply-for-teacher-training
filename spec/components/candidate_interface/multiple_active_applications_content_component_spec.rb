require 'rails_helper'

RSpec.describe CandidateInterface::MultipleActiveApplicationsContentComponent do
  let(:application_form) { create(:application_form) }

  subject(:component) { described_class.new(application_form:) }

  describe 'delegations' do
    it { is_expected.to delegate_method(:candidate).to(:application_form) }
    it { is_expected.to delegate_method(:active_previous_application).to(:candidate) }
  end

  describe 'rendered' do
    subject(:rendered) { component.render? }

    let(:rendered_component) { render_inline(described_class.new(application_form:)) }

    context 'when the candidate has previous active applications' do
      let(:previous_application) do
        create(
          :application_form,
          candidate: application_form.candidate,
          recruitment_cycle_year: application_form.recruitment_cycle_year - 1,
          created_at: application_form.created_at - 1.year,
        )
      end
      let(:jan_course) { build(:course, start_date: "01/01/#{application_form.recruitment_cycle_year}") }
      let(:jan_course_option) { build(:course_option, course: jan_course) }
      let(:jan_application_choice) do
        create(
          :application_choice,
          :awaiting_provider_decision,
          current_recruitment_cycle_year: previous_application.recruitment_cycle_year,
          course_option: jan_course_option,
          application_form: previous_application,
        )
      end

      before { jan_application_choice }

      it 'renders the january start component for the previous active applications' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(
          :h1,
          text: 'Your applications',
          class: 'govuk-heading-xl',
        )

        expect(rendered_component).to have_element(
          :h2,
          text: "Courses starting by January #{application_form.recruitment_cycle_year}",
          class: 'govuk-heading-l',
        )
        expect(rendered_component).to have_element(
          :p,
          text: "Providers have until #{previous_application.recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first)} " \
                'to make decisions on these applications.',
          class: 'govuk-body',
        )
        expect(rendered_component).to have_element(
          :div,
          text: jan_application_choice.course.name,
          class: 'app-application-item',
        )

        expect(rendered_component).to have_element(
          :h2,
          text: "Courses for the #{application_form.academic_year_range_name} academic year",
          class: 'govuk-heading-l',
        )
      end
    end

    context 'when the candidate does not have previous active applications' do
      it 'does not render' do
        expect(rendered).to be(false)
      end
    end
  end
end
