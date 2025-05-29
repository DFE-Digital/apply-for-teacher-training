require 'rails_helper'

RSpec.describe CandidateInterface::SponsorshipApplicationDeadlines::ApplicationsDashboardBannerComponent do
  context 'with a single relevant application choice' do
    let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at:)) }
    let(:course_option_without_deadline) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: nil)) }
    let(:application_form) { create(:application_form, right_to_work_or_study: 'no') }

    before do
      create(:application_choice, :unsubmitted, course_option: course_option, application_form:)
      create(:application_choice, :unsubmitted, course_option: course_option_without_deadline, application_form:)
    end

    context 'when the deadline for one course is today' do
      let(:visa_sponsorship_application_deadline_at) { 5.hours.from_now }

      it 'renders the the deadline at time' do
        rendered = render_inline(described_class.new(application_form:))

        expect(rendered).to have_text("Submit your application for #{course_option.course.name_and_code} at #{course_option.course.provider.name} soon")
        expect(rendered).to have_text("The deadline for applications that need visa sponsorship is at #{visa_sponsorship_application_deadline_at.to_fs(:govuk_time)} today")
        expect(rendered).to have_no_text(course_option_without_deadline.course.name_and_code)
      end
    end

    context 'when the deadline is one day away' do
      let(:visa_sponsorship_application_deadline_at) { 1.day.from_now + 2.hours }

      it 'renders the text for one day' do
        rendered = render_inline(described_class.new(application_form:))

        expect(rendered).to have_text("Submit your application for #{course_option.course.name_and_code} at #{course_option.course.provider.name} soon")
        expect(rendered).to have_text('The deadline for applications that need visa sponsorship is in 1 day')
        expect(rendered).to have_no_text(course_option_without_deadline.course.name_and_code)
      end
    end

    context 'when the deadline is between 2-19 days away' do
      let(:visa_sponsorship_application_deadline_at) { 19.days.from_now + 2.hours }

      it 'renders the text for one day' do
        rendered = render_inline(described_class.new(application_form:))

        expect(rendered).to have_text("Submit your application for #{course_option.course.name_and_code} at #{course_option.course.provider.name} soon")
        expect(rendered).to have_text('The deadline for applications that need visa sponsorship is in 19 days')
        expect(rendered).to have_no_text(course_option_without_deadline.course.name_and_code)
      end
    end

    context 'when the deadline is more than 20 days away' do
      let(:visa_sponsorship_application_deadline_at) { 20.days.from_now + 2.hours }

      it 'does not render the component' do
        rendered = render_inline(described_class.new(application_form:))

        expect(rendered.text).to eq ''
      end
    end

    context 'when the deadline has passed' do
      let(:visa_sponsorship_application_deadline_at) { 1.second.ago }

      it 'does not render the component' do
        rendered = render_inline(described_class.new(application_form:))

        expect(rendered.text).to eq ''
      end
    end
  end

  context 'with multiple relevant applications' do
    let(:application_form) { create(:application_form, right_to_work_or_study: 'no') }

    context 'with deadlines of today, 1 day from now, and between 2-19 days' do
      let(:today) { 3.hours.from_now }
      let(:course_option_with_today) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: today)) }
      let(:course_option_with_19_days_from_now) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 19.days.from_now + 2.hours)) }
      let(:course_option_with_one_day_from_now) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 1.day.from_now + 2.hours)) }

      before do
        [course_option_with_today, course_option_with_19_days_from_now, course_option_with_one_day_from_now].each do |course_option|
          create(:application_choice, :unsubmitted, course_option:, application_form:)
        end
      end

      it 'renders all three deadlines as expected' do
        rendered = render_inline(described_class.new(application_form:))
        expect(rendered).to have_text 'Submit your applications soon'
        expect(rendered).to have_text 'The deadlines for these courses that need visa sponsorship are approaching'
        expect(rendered).to have_text(
          "#{course_option_with_today.course.name_and_code} at #{course_option_with_today.course.provider.name} - deadline at #{today.to_fs(:govuk_time)}",
        )
        expect(rendered).to have_text(
          "#{course_option_with_one_day_from_now.course.name_and_code} at #{course_option_with_one_day_from_now.course.provider.name} - deadline in 1 day",
        )
        expect(rendered).to have_text(
          "#{course_option_with_19_days_from_now.course.name_and_code} at #{course_option_with_19_days_from_now.course.provider.name} - deadline in 19 day",
        )
      end
    end
  end

  context 'when application form does not require visa sponsorship' do
    let(:application_form) { create(:application_form, right_to_work_or_study: nil) }
    let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 2.days.from_now)) }

    before do
      create(:application_choice, :unsubmitted, course_option:, application_form:)
    end

    it 'does not render component' do
      rendered = render_inline(described_class.new(application_form:))
      expect(rendered.text).to eq ''
    end
  end

  context 'when application choice is submitted' do
    let(:application_form) { create(:application_form, right_to_work_or_study: 'no') }
    let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 2.days.from_now)) }

    before do
      create(:application_choice, :awaiting_provider_decision, course_option:, application_form:)
    end

    it 'does not render component' do
      rendered = render_inline(described_class.new(application_form:))
      expect(rendered.text).to eq ''
    end
  end
end
