require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::SeptemberStartContentComponent do
  let(:application_form) { create(:application_form, recruitment_cycle_year: 2026) }
  let(:component) { described_class.new(application_form:) }
  let(:recruitment_cycle_timetable) { application_form.recruitment_cycle_timetable }

  describe '#render?' do
    subject(:rendered) { component.render? }

    let(:course) { build(:course, start_date: "01/09/#{application_form.recruitment_cycle_year}") }
    let(:course_option) { build(:course_option, course:) }
    let(:application_choice) { create(:application_choice, course_option:, application_form:) }
    let(:rendered_component) { render_inline(described_class.new(application_form:)) }

    before { application_choice }

    context 'when the application form has application choices with courses starting in September' do
      it 'renders the content' do
        expect(rendered).to be(true)

        expect(rendered_component).to have_element(
                                        :h2,
                                        text: 'Courses starting by September 2026',
                                        class: 'govuk-heading-l',
                                        )

        expect(rendered_component).to have_element(
                                        :div,
                                        text: application_choice.course.name,
                                        class: 'app-application-item'
                                      )
      end
    end

    context 'when the application form has no application choices with courses starting in September' do
      let(:course) { build(:course, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}") }

      it 'does not render the content' do
        expect(rendered).to be(false)
      end
    end
  end

  describe '#heading' do
    context 'when not given a custom heading' do
      it 'renders the component heading containing the academic year' do
        expect(component.heading).to eq("Courses starting by September 2026")
      end
    end

    context 'when given a custom heading' do
      let(:component) { described_class.new(application_form:, heading: 'What happens next?') }

      it 'renders the custom heading' do
        expect(component.heading).to eq("What happens next?")
      end
    end
  end
end
