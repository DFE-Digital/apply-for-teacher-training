require 'rails_helper'

RSpec.describe CandidateInterface::AfterDeadlineContentComponent do
  context 'can carry over' do
    it 'shows text about carrying over' do
      application_form = create(:application_form)
      travel_temporarily_to(application_form.apply_deadline_at + 1.day) do
        component = render_inline(described_class.new(application_form:))

        expect(component).to have_button('Update your details')

        next_year_range = next_timetable.academic_year_range_name
        expect(component).to have_text "Apply to courses in the #{next_year_range} academic year"

        expect(component).to have_text "You will be able to view courses on Find teacher training courses from #{next_timetable.find_opens_at.to_fs(:govuk_date_time_time_first)}."
        expect(component).to have_text "You can apply for courses from #{next_timetable.apply_opens_at.to_fs(:govuk_date_time_time_first)}."
      end
    end
  end

  context 'cannot carry over' do
    it 'does not show carry over content' do
      application_form = create(
        :application_form,
        :submitted,
        application_choices: [build(:application_choice, :offered)],
      )
      travel_temporarily_to(application_form.decline_by_default_at - 1.day) do
        component = render_inline(described_class.new(application_form:))
        expect(component).to have_no_button('Update your details')

        next_year_range = next_timetable.academic_year_range_name
        expect(component).to have_no_text "Apply to courses in the #{next_year_range} academic year"
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
        expect(component).to have_text(
          "If you don’t hear back from training providers about your applications before #{application_form.reject_by_default_at.to_fs(:govuk_date_time_time_first)} then they will be rejected automatically.",
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
        expect(component).to have_text(
          "You have until #{application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first)} to respond to any offers you receive. They will be declined on your behalf if you don’t respond before this time.",
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
        expect(component).to have_text(
          "Any offers that you had received have been declined on your behalf because you did not respond before the deadline of #{application_form.decline_by_default_at.to_fs(:govuk_date_time_time_first)}. Contact the training provider if you need to discuss this.",
        )
      end
    end
  end
end
