require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::JanuaryStartContentComponent do
  let(:application_form) { create(:application_form, recruitment_cycle_year: 2026) }
  let(:component) { described_class.new(application_form:) }
  let(:recruitment_cycle_timetable) { application_form.recruitment_cycle_timetable }

  describe '#render?' do
    subject(:rendered) { component.render? }

    let(:course) { build(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
    let(:course_option) { build(:course_option, course:) }
    let(:application_choice) { create(:application_choice, course_option:, application_form:) }
    let(:rendered_component) { render_inline(described_class.new(application_form:)) }

    before { application_choice }

    context 'when the application form has application choices with courses starting in January' do
      it 'renders the content' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(
          :h2,
          text: 'Courses starting by January 2027',
          class: 'govuk-heading-l',
        )
        expect(rendered_component).to have_element(
          :p,
          text: "Providers have until #{recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first)} " \
            'to make decisions on these applications.',
          class: 'govuk-body',
        )
        expect(rendered_component).to have_element(
          :div,
          text: application_choice.course.name,
          class: 'app-application-item'
        )
      end
    end

    context 'when the application form has no application choices with courses starting in January' do
      let(:course) { build(:course, start_date: "01/09/#{application_form.recruitment_cycle_year}") }

      it 'does not render the content' do
        expect(rendered).to be(false)
      end
    end
  end

  describe '#title' do
    it 'returns the title of the component with the correct academic year' do
      expect(component.title).to eq('Courses starting by January 2027')
    end
  end

  describe '#provider_deadline_content' do
    it 'returns content for providers regarding the winter reject by default date' do
      expect(component.provider_deadline_content).to eq(
        "Providers have until #{recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first)} " \
          'to make decisions on these applications.'
      )
    end
  end

  describe '#application_choices' do
    let(:sept_course) { build(:course, start_date: "01/09/#{application_form.recruitment_cycle_year}") }
    let(:sept_course_option) { build(:course_option, course: sept_course) }
    let(:sept_application_choice) { create(:application_choice, course_option: sept_course_option, application_form:) }
    let(:jan_course) { build(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }
    let(:jan_course_option) { build(:course_option, course: jan_course) }
    let(:jan_application_choice) { create(:application_choice, course_option: jan_course_option, application_form:) }

    before do
      sept_application_choice
      jan_application_choice
    end

    it 'returns on application choices with january start dates' do
      expect(component.application_choices).to contain_exactly(jan_application_choice)
    end
  end
end
