require 'rails_helper'

RSpec.describe CandidateInterface::AfterDeadlineContentComponent do
  context 'carried over' do
    it 'shows text about carrying over' do
      application_form = create(:application_form)
      travel_temporarily_to(application_form.find_opens_at + 1.day) do
        component = render_inline(described_class.new(application_form:))

        year_range = application_form.academic_year_range_name
        expect(component).to have_text "Apply to courses in the #{year_range} academic year"
        expect(component).to have_link('Choose a course', class: 'govuk-button')

        expect(component).to have_text "You will be able to view courses on Find teacher training courses from #{application_form.find_opens_at.to_fs(:govuk_date_time_time_first)}."
        expect(component).to have_text "You can apply for courses from #{application_form.apply_opens_at.to_fs(:govuk_date_time_time_first)}."
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
        expect(component).to have_text "Apply to courses in the #{next_year_range} academic year"
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
        expect(component).to have_text application_form.reject_by_default_at.to_fs(:govuk_date_and_time)
        expect(component).to have_text(
          'Applications that are awaiting provider decision or interviewing will be rejected automatically.',
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
          "Some of your applications have been rejected automatically. This is because training providers did not respond to them before the deadline of #{application_form.reject_by_default_at.to_fs(:govuk_date_time_time_first)}",
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
        expect(component).to have_text(application_form.decline_by_default_at.to_fs(:govuk_date_and_time))
        expect(component).to have_text(
          'You must respond to your offers before this time. They will be declined on your behalf if you don’t.',
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
          "Any offers that you had received have been declined on your behalf because you did not respond before the deadline of #{application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first)}. Contact the training provider if you need to discuss this.",
        )
      end
    end
  end
end
