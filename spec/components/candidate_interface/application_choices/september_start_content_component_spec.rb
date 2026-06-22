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
          class: 'app-application-item',
        )
      end

      context 'when the application form has an application choice which has been rejected by default' do
        let(:application_choice) { create(:application_choice, :rejected_by_default, course_option:, application_form:) }

        it 'renders the rejected by default content' do
          expect(rendered_component).to have_element(
            :p,
            text: 'Some of your applications have been rejected because the provider did not respond before the deadline.',
            class: 'govuk-body',
          )
        end
      end

      context 'when the application form has an application choice which has been declined by default' do
        let(:application_choice) { create(:application_choice, :declined_by_default, course_option:, application_form:) }

        it 'renders the rejected by default content' do
          expect(rendered_component).to have_element(
            :p,
            text: 'Some of your offers have been declined because you did not respond before the deadline.',
            class: 'govuk-body',
          )
        end
      end

      context 'when the application form has an application choice pending a decision' do
        let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:, application_form:) }

        it 'renders the rejected by default content' do
          expect(rendered_component).to have_element(
            :h3,
            text: 'Applications awaiting a provider decision',
            class: 'govuk-heading-s',
          )
          expect(rendered_component).to have_element(
            :p,
            text: 'Applications will be rejected automatically at ' \
                  "#{recruitment_cycle_timetable.reject_by_default_at.to_fs(:govuk_date_time_time_first)} if providers do not respond.",
            class: 'govuk-body',
          )
        end
      end

      context 'when the application form has an application choice that has been offered' do
        let(:application_choice) { create(:application_choice, :offered, course_option:, application_form:) }

        it 'renders the rejected by default content' do
          expect(rendered_component).to have_element(
            :h3,
            text: 'Offers awaiting your response',
            class: 'govuk-heading-s',
          )
          expect(rendered_component).to have_element(
            :p,
            text: 'Offers will be declined automatically at ' \
                  "#{recruitment_cycle_timetable.decline_by_default_at.to_fs(:govuk_date_time_time_first)} if you do not respond.",
            class: 'govuk-body',
          )
        end
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
        expect(component.heading).to eq('Courses starting by September 2026')
      end
    end

    context 'when given a custom heading' do
      let(:component) { described_class.new(application_form:, heading: 'What happens next?') }

      it 'renders the custom heading' do
        expect(component.heading).to eq('What happens next?')
      end
    end
  end

  describe '#awaiting_provider_decision_content' do
    let(:course) { build(:course, start_date: "01/09/#{application_form.recruitment_cycle_year}") }
    let(:course_option) { build(:course_option, course:) }
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option:, application_form:) }

    before { application_choice }

    context 'when the application form has an application choice pending a decision' do
      it 'renders the content' do
        content = component.awaiting_provider_decision_content
        expect(content[:title]).to eq('Applications awaiting a provider decision')
        expect(content[:content]).to eq(
          'Applications will be rejected automatically at ' \
          "#{recruitment_cycle_timetable.reject_by_default_at.to_fs(:govuk_date_time_time_first)} if providers do not respond.",
        )
      end
    end

    context 'when the application form does not have an application choice pending a decision' do
      let(:application_choice) { create(:application_choice, course_option:, application_form:) }

      it 'does not render the content' do
        expect(component.awaiting_provider_decision_content).to be_nil
      end
    end
  end

  describe '#reject_by_default_explanation' do
    let(:course) { build(:course, start_date: "01/09/#{application_form.recruitment_cycle_year}") }
    let(:course_option) { build(:course_option, course:) }
    let(:application_choice) { create(:application_choice, :rejected_by_default, course_option:, application_form:) }

    before { application_choice }

    context 'when the application form has an application choice which has been rejected by default' do
      it 'renders the content' do
        expect(component.reject_by_default_explanation).to eq(
          'Some of your applications have been rejected because the provider did not respond before the deadline.',
        )
      end
    end

    context 'when the application form does not have an application choice pending a decision' do
      let(:application_choice) { create(:application_choice, course_option:, application_form:) }

      it 'does not render the content' do
        expect(component.reject_by_default_explanation).to be_nil
      end
    end
  end

  describe '#decline_by_default_explanation' do
    let(:course) { build(:course, start_date: "01/09/#{application_form.recruitment_cycle_year}") }
    let(:course_option) { build(:course_option, course:) }
    let(:application_choice) { create(:application_choice, :declined_by_default, course_option:, application_form:) }

    before { application_choice }

    context 'when the application form has an application choice which has been rejected by default' do
      it 'renders the content' do
        expect(component.decline_by_default_explanation).to eq(
          'Some of your offers have been declined because you did not respond before the deadline.',
        )
      end
    end

    context 'when the application form does not have an application choice pending a decision' do
      let(:application_choice) { create(:application_choice, course_option:, application_form:) }

      it 'does not render the content' do
        expect(component.decline_by_default_explanation).to be_nil
      end
    end
  end

  describe '#offered_content' do
    let(:course) { build(:course, start_date: "01/09/#{application_form.recruitment_cycle_year}") }
    let(:course_option) { build(:course_option, course:) }
    let(:application_choice) { create(:application_choice, :offered, course_option:, application_form:) }

    before { application_choice }

    context 'when the application form has an application choice that has been offered' do
      it 'renders the content' do
        content = component.offered_content
        expect(content[:title]).to eq('Offers awaiting your response')
        expect(content[:content]).to eq(
          'Offers will be declined automatically at ' \
          "#{recruitment_cycle_timetable.decline_by_default_at.to_fs(:govuk_date_time_time_first)} if you do not respond.",
        )
      end
    end

    context 'when the application form does not have an application choice pending a decision' do
      let(:application_choice) { create(:application_choice, course_option:, application_form:) }

      it 'does not render the content' do
        expect(component.offered_content).to be_nil
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
      expect(component.application_choices).to contain_exactly(sept_application_choice)
    end
  end
end
