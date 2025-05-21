require 'rails_helper'

RSpec.describe CandidateInterface::SponsorshipApplicationDeadlines::ApplicationChoiceBannerComponent do
  context 'unsubmitted choice requires sponsorship and course has deadlines' do
    let(:application_form) { create(:application_form, right_to_work_or_study: 'no') }
    let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at:)) }

    context 'deadline less than 1 day from now' do
      let(:visa_sponsorship_application_deadline_at) { 4.hours.from_now }

      it 'renders text for less than one day' do
        application_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
        rendered = render_inline(described_class.new(application_choice:))

        expect(rendered).to have_text("Submit this application soon. The deadline for applications that need visa sponsorship is at #{visa_sponsorship_application_deadline_at.to_fs(:govuk_time)} today.")
      end
    end

    context 'deadline 1 day from now' do
      let(:visa_sponsorship_application_deadline_at) { 1.day.from_now + 2.hours }

      it 'renders text for one day' do
        application_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
        rendered = render_inline(described_class.new(application_choice:))

        expect(rendered).to have_text('Submit this application soon. The deadline for applications that need visa sponsorship is in 1 day')
      end
    end

    context 'deadline 19 days from now' do
      let(:visa_sponsorship_application_deadline_at) { 19.days.from_now + 2.hours }

      it 'renders text for 19 days from now' do
        application_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
        rendered = render_inline(described_class.new(application_choice:))

        expect(rendered).to have_text('Submit this application soon. The deadline for applications that need visa sponsorship is in 19 days')
      end
    end

    context 'deadline 20 days from now' do
      let(:application_form) { create(:application_form, right_to_work_or_study: 'no') }
      let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 20.days.from_now + 1.second)) }

      it 'does not render component' do
        application_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
        rendered = render_inline(described_class.new(application_choice:))

        expect(rendered.text).to eq ''
      end
    end

    context 'deadline has passed' do
      let(:application_form) { create(:application_form, right_to_work_or_study: 'no') }
      let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 1.second.ago)) }

      it 'does not render component' do
        application_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
        rendered = render_inline(described_class.new(application_choice:))

        expect(rendered.text).to eq ''
      end
    end
  end

  context 'application form does not require sponsorship' do
    let(:application_form) { create(:application_form, right_to_work_or_study: nil) }
    let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 4.days.from_now)) }

    it 'does not render component' do
      application_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
      rendered = render_inline(described_class.new(application_choice:))

      expect(rendered.text).to eq ''
    end
  end

  context 'course does not have a visa sponsorship application deadline' do
    let(:application_form) { create(:application_form, right_to_work_or_study: nil) }
    let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: nil)) }

    it 'does not render component' do
      application_choice = create(:application_choice, :unsubmitted, course_option:, application_form:)
      rendered = render_inline(described_class.new(application_choice:))

      expect(rendered.text).to eq ''
    end
  end

  context 'choice has been submitted' do
    let(:application_form) { create(:application_form, right_to_work_or_study: 'no') }
    let(:course_option) { create(:course_option, course: create(:course, visa_sponsorship_application_deadline_at: 4.days.from_now)) }

    it 'does not render component' do
      application_choice = create(:application_choice, :awaiting_provider_decision, course_option:, application_form:)
      rendered = render_inline(described_class.new(application_choice:))

      expect(rendered.text).to eq ''
    end
  end
end
