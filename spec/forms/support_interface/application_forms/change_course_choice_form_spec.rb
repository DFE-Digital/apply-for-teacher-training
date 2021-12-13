require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::ChangeCourseChoiceForm, type: :model, with_audited: true do
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
      it 'raises an ActiveRecord error' do
        first_course_option = create(:course_option)
        second_course_option = create(:course_option)
        application_form = create(:application_form)
        application_choice_to_change = create(:application_choice, :awaiting_provider_decision, course_option: first_course_option, application_form: application_form)
        create(:application_choice, :awaiting_provider_decision, course_option: second_course_option, application_form: application_form)

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

        expect { form.save(application_choice_to_change.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'if the new course is not a valid choice' do
      it 'raises an ActiveRecord error' do
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

        expect { form.save(application_choice.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'if the new course details are correct' do
      it 'updates the application choice' do
        original_course_option = create(:course_option)
        application_choice = create(:application_choice, :awaiting_provider_decision, course_option: original_course_option)

        course_option = create(:course_option, study_mode: :full_time)
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

        expect(form.save(application_choice.id)).to eq(true)

        expect(application_choice.reload.course.name).to eq course_option.course.name
        expect(application_choice.course.id).not_to eq original_course_option.course.id
        expect(application_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end
  end
end
