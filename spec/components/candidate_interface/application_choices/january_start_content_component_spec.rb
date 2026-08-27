require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::JanuaryStartContentComponent do
  let(:application_form) { create(:application_form, recruitment_cycle_year: current_year) }
  let(:component) { described_class.new(application_form:) }
  let(:recruitment_cycle_timetable) { application_form.recruitment_cycle_timetable }

  describe '#render?' do
    subject(:rendered) { component.render? }

    let(:course) { build(:course, start_date: "01/01/#{next_year}") }
    let(:course_option) { build(:course_option, course:) }
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:, application_form:) }
    let(:rendered_component) { render_inline(described_class.new(application_form:)) }

    before { application_choice }

    context 'when the application form has application choices with courses starting in January' do
      it 'renders the content' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(
          :h2,
          text: "Courses starting in January #{next_year}",
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
          class: 'app-application-item',
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
    context 'all course start dates are in one month' do
      it 'returns the title of the component with the specific month and year' do
        course = create(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}")
        create(:application_choice, application_form:, course_option: build(:course_option, course:))
        expect(component.title).to eq("Courses starting in January #{next_year}")
      end
    end

    context 'course start dates are in multiple months' do
      let(:dec_course) { build(:course, start_date: "01/10/#{application_form.recruitment_cycle_year}") }
      let(:jan_course) { build(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }

      it 'returns generic title with correct year' do
        create(:application_choice, course_option: build(:course_option, course: jan_course), application_form:)
        create(:application_choice, course_option: build(:course_option, course: dec_course), application_form:)
        expect(component.title).to eq("Courses starting by the end of January #{next_year}")
      end
    end
  end

  describe '#provider_deadline_content' do
    let(:course) { build(:course, start_date: "01/01/#{next_year}") }
    let(:course_option) { build(:course_option, course:) }

    before { application_choice }

    %i[awaiting_provider_decision interviewing offer pending_conditions recruited offer_deferred].each do |state|
      context "when the application choice has state #{state}" do
        let(:application_choice) { create(:application_choice, state, course_option:, application_form:) }

        it 'returns content for providers regarding the winter reject by default date' do
          expect(component.provider_deadline_content).to eq(
            "Providers have until #{recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first)} " \
            'to make decisions on these applications.',
          )
        end
      end
    end

    %i[unsubmitted cancelled inactive rejected application_not_sent offer_withdrawn declined withdrawn conditions_not_met].each do |state|
      context "when the application choice has state #{state}" do
        let(:application_choice) { create(:application_choice, state, course_option:, application_form:) }

        it 'returns nil' do
          expect(component.provider_deadline_content).to be_nil
        end
      end
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
