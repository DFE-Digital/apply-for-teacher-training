require 'rails_helper'

RSpec.describe CandidateInterface::AfterDeadlineContentComponent do
  context 'carried over' do
    context 'before find opens' do
      it 'shows text about carrying over' do
        application_form = create(:application_form, recruitment_cycle_year: 2027)
        travel_temporarily_to(application_form.find_opens_at - 1.day) do
          component = render_inline(described_class.new(application_form:))

          expect(component).to have_element(:h1, text: "Your applications", class: "govuk-heading-xl")
          expect(component).to have_element(:p, text: "The deadline for applying to courses in the 2026 to 2027 academic year had passed.", class: "govuk-body")
          expect(component).to have_no_link('Choose a course', class: 'govuk-button')

          expect(component).to have_element(:h2, text: "Courses from the 2027 to 2028 academic year", class: "govuk-heading-l")
          expect(component).to have_text "You will be able to view courses starting in the 2027 to 2028 academic year from #{application_form.find_opens_at.to_fs(:govuk_date_time_time_first)}."
          expect(component).to have_text "You will be able to apply from #{application_form.apply_opens_at.to_fs(:govuk_date_time_time_first)}."
        end
      end
    end

    context 'after find opens' do
      it 'shows text about carrying over' do
        application_form = create(:application_form, recruitment_cycle_year: 2027)
        travel_temporarily_to(application_form.find_opens_at + 1.day) do
          component = render_inline(described_class.new(application_form:))

          expect(component).to have_element(:h1, text: "Your applications", class: "govuk-heading-xl")
          expect(component).to have_element(:p, text: "The deadline for applying to courses in the 2026 to 2027 academic year had passed.", class: "govuk-body")
          expect(component).to have_link('Choose a course', class: 'govuk-button')

          expect(component).to have_element(:h2, text: "Courses from the 2027 to 2028 academic year", class: "govuk-heading-l")
          expect(component).to have_text "You can now find teacher training courses starting in the 2027 to 2028 academic year."
          expect(component).to have_text "You will be able to apply from 9am UK time on 6 October 2026, but you can start preparing your application now."
        end
      end
    end
  end

  context 'cannot carry over' do
    it 'does not show choose a course button' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :offered)],
      )
      travel_temporarily_to(application_form.decline_by_default_at - 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')

        next_year_range = next_timetable.academic_year_range_name
        expect(component).to have_text "Courses from the #{next_year_range} academic year"
      end
    end
  end

  context 'has awaiting provider decision before reject by default at' do
    it 'shows reject by default warning text' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :awaiting_provider_decision)],
      )

      travel_temporarily_to(application_form.reject_by_default_at - 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text application_form.reject_by_default_at.to_fs(:govuk_date_time_time_first)
        expect(component).to have_text(
          'Applications awaiting a provider decision Applications will be rejected automatically',
        )
      end
    end
  end

  context 'application has been rejected by default' do
    it 'shows reject by default explanation' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :rejected_by_default)],
      )
      travel_temporarily_to(application_form.reject_by_default_at + 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text(
          "Some of your applications have been rejected because the provider did not respond before the deadline.",
        )
      end
    end
  end

  context 'has offers and it is before decline by default at' do
    it 'shows the decline by default warning' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :offer)],
      )
      travel_temporarily_to(application_form.decline_by_default_at - 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text(application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first))
        expect(component).to have_text(
          "Offers will be declined automatically at #{application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first)} if you do not respond.",
        )
      end
    end
  end

  context 'an application has been declined by default' do
    it 'shows the decline by default explanation' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :declined_by_default)],
      )
      travel_temporarily_to(application_form.decline_by_default_at + 1.minute) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_link('Choose a course', class: 'govuk-button')
        expect(component).to have_text(
          "Some of your offers have been declined because you did not respond before the deadline.",
        )
      end
    end
  end

  describe '#academic_year' do
    subject(:academic_year) { described_class.new(application_form:).academic_year }

    context 'when the apply deadline has passed' do
      let(:application_form) { create(:application_form) }

      before do
        allow(application_form).to receive(:after_apply_deadline?).and_return(true)
      end

      it 'returns the applications academic year range name' do
        expect(academic_year).to eq(application_form.academic_year_range_name)
      end
    end

    context 'when the apply deadline has not passed' do
      context 'when the application form has been carried over' do
        let(:application_form) { create(:application_form, :carry_over) }

        it 'returns the previous academic year range name' do
          expect(academic_year).to eq(application_form.previous_application_form.academic_year_range_name)
        end
      end

      context 'when the application form has not been carried over' do
        let(:application_form) { create(:application_form) }

        before do
          allow(application_form).to receive(:after_apply_deadline?).and_return(true)
        end

        it 'returns the applications academic year range name' do
          expect(academic_year).to eq(application_form.academic_year_range_name)
        end
      end
    end
  end
end
