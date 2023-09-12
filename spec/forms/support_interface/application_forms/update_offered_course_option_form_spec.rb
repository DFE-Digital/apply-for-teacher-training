require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::UpdateOfferedCourseOptionForm, :with_audited do
  describe '#validations' do
    it { is_expected.to validate_presence_of(:course_option_id) }
    it { is_expected.to validate_presence_of(:audit_comment) }
    it { is_expected.to validate_presence_of(:accept_guidance) }

    context 'for an invalid zendesk link' do
      invalid_link = 'nonsense'
      it { is_expected.not_to allow_value(invalid_link).for(:audit_comment) }
    end

    context 'for an valid zendesk link' do
      valid_link = 'www.becomingateacher.zendesk.com/agent/tickets/example'
      it { is_expected.to allow_value(valid_link).for(:audit_comment) }
    end
  end

  describe '#save' do
    let(:zendesk_ticket) { 'www.becomingateacher.zendesk.com/agent/tickets/example' }
    let(:fee_paying_course) { create(:course, :fee_paying) }

    it 'updates the offered course option' do
      application_choice = create(:application_choice, :offered)
      replacement_course_option = create(:course_option, course: fee_paying_course)

      described_class.new(course_option_id: replacement_course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)

      expect(application_choice.reload.current_course_option_id).to eq replacement_course_option.id
      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
    end

    context 'course full check' do
      let(:application_choice) { create(:application_choice, :offered) }

      it 'raises a CourseFullError if the new course has no vacancies' do
        course_option = create(:course_option, :no_vacancies, course: fee_paying_course)
        error_message = I18n.t('support_interface.errors.messages.course_full_error')

        expect {
          described_class.new(course_option_id: course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)
        }.to raise_error(CourseFullError, error_message)
      end

      it 'does not raise a CourseFullError if confirm_course_change is true' do
        course_option = create(:course_option, :no_vacancies, course: fee_paying_course)

        expect {
          described_class.new(course_option_id: course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true', confirm_course_change: 'true').save(application_choice)
        }.not_to raise_error
      end
    end

    context 'if the offer has SKE conditions' do
      let(:application_choice) { create(:application_choice, :offered, offer: build(:offer, :with_ske_conditions)) }

      it 'deletes the SKE conditions' do
        expect(application_choice.offer.ske_conditions).to be_any

        new_course = create(:course, funding_type: application_choice.current_course.funding_type)
        described_class.new(course_option_id: create(:course_option, course: new_course).id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)

        expect(application_choice.reload.offer.ske_conditions).to be_empty
      end
    end
  end
end
