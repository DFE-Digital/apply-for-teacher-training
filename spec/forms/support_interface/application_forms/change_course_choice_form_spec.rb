require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::ChangeCourseChoiceForm, :with_audited, type: :model do
  include CourseOptionHelpers

  describe 'validations' do
    it { is_expected.to validate_presence_of(:accept_guidance) }
    it { is_expected.to validate_presence_of(:audit_comment_ticket) }
    it { is_expected.to validate_presence_of(:provider_code) }
    it { is_expected.to validate_presence_of(:course_code) }
    it { is_expected.to validate_presence_of(:study_mode) }
    it { is_expected.to validate_presence_of(:site_code) }

    context 'for an invalid zendesk link' do
      invalid_link = 'nonsense'
      it { is_expected.not_to allow_value(invalid_link).for(:audit_comment_ticket) }
    end

    context 'for an valid zendesk link' do
      valid_link = 'www.becomingateacher.zendesk.com/agent/tickets/example'
      it { is_expected.to allow_value(valid_link).for(:audit_comment_ticket) }
    end
  end

  describe '#save!' do
    context 'if the new course is already an existing choice' do
      it 'raises a CourseChoiceError error' do
        first_course_option = create(:course_option)
        second_course_option = create(:course_option, course: create(:course, funding_type: 'fee'))
        application_form = create(:application_form)
        application_choice_to_change = create(:application_choice, :awaiting_provider_decision, course_option: first_course_option, application_form:)
        create(:application_choice, :awaiting_provider_decision, course_option: second_course_option, application_form:)

        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice_to_change.id,
          provider_code: second_course_option.provider.code,
          course_code: second_course_option.course.code,
          study_mode: second_course_option.study_mode,
          site_code: second_course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect { form.save(application_choice_to_change.id) }.to raise_error(CourseChoiceError, 'This course option has already been taken')
      end
    end

    context 'if the new course is not a valid choice' do
      it 'raises a CourseChoiceError error' do
        original_course_option = create(:course_option)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)

        course_option = create(:course_option, study_mode: :full_time)
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: :part_time,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect { form.save(application_choice.id) }.to raise_error(CourseChoiceError, 'This is not a valid course option')
      end
    end

    context 'if the provider code is not a valid entry' do
      it 'raises a CourseChoiceError error' do
        original_course_option = create(:course_option)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)

        course_option = create(:course_option, study_mode: :full_time)
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: 'nonsense',
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect { form.save(application_choice.id) }.to raise_error(CourseChoiceError, 'This is not a valid provider code')
      end
    end

    context 'if the new provider is not on the interview' do
      it 'raises a ProviderInterviewError' do
        original_course_option = create(:course_option)
        application_choice = create(:application_choice, :interviewing, course_option: original_course_option)

        other_provider = create(:provider)
        other_course = create(:course, provider: other_provider)
        other_course_option = create(:course_option, course: other_course, study_mode: :full_time)
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: other_provider.code,
          course_code: other_course_option.course.code,
          study_mode: other_course_option.course.study_mode,
          site_code: other_course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect { form.save(application_choice.id) }.to raise_error(ProviderInterviewError)
      end
    end

    context 'if the new course details are correct' do
      it 'updates the application choice' do
        original_course_option = create(:course_option)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)

        course_option = create(:course_option)
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice.id)).to be(true)

        expect(application_choice.reload.course.name).to eq course_option.course.name
        expect(application_choice.course.id).not_to eq original_course_option.course.id
        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end

    context 'if the new course details are for a previous recruitment cycle' do
      it 'updates the application choice' do
        original_course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 2024))
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)

        course_option = create(:course_option, course: create(:course, recruitment_cycle_year: 2024))
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          recruitment_cycle_year: 2024,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice.id)).to be(true)

        expect(application_choice.reload.course.name).to eq course_option.course.name
        expect(application_choice.course.id).not_to eq original_course_option.course.id
        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end

    context 'if the existing course has a ske condition' do
      it 'removes the ske condition' do
        original_course_option = create(:course_option)
        offer_with_ske = create(:offer, :with_ske_conditions)
        application_choice = create(:application_choice, :offer, offer: offer_with_ske, course_option: original_course_option)

        course_option = create(:course_option, study_mode: :full_time, course: create(:course, funding_type: 'fee'))
        zendesk_ticket = 'https://becomingateacher.zendesk.com/agent/tickets/12345'

        form = described_class.new(
          application_choice_id: application_choice.id,
          provider_code: course_option.provider.code,
          course_code: course_option.course.code,
          study_mode: course_option.course.study_mode,
          site_code: course_option.site.code,
          audit_comment_ticket: zendesk_ticket,
          accept_guidance: true,
        )

        expect(form.save(application_choice.id)).to be(true)

        expect(application_choice.reload.course.name).to eq course_option.course.name
        expect(application_choice.course.id).not_to eq original_course_option.course.id
        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
        expect(application_choice.reload.offer.ske_conditions).to be_empty
      end
    end
  end
end
