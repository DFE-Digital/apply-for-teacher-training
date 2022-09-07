require 'rails_helper'

RSpec.describe SupportInterface::ApplicationForms::UpdateOfferedCourseOptionForm, with_audited: true do
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
    let(:fee_paying_course) { create(:course, funding_type: 'fee') }

    it 'updates the offered course option' do
      application_choice = create(:application_choice, status: :offer)
      replacement_course_option = create(:course_option, course: fee_paying_course)

      described_class.new(course_option_id: replacement_course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)

      expect(application_choice.reload.current_course_option_id).to eq replacement_course_option.id
      expect(application_choice.audits.last.comment).to include(zendesk_ticket)
    end

    context 'course choice funding type check' do
      let(:salaried_course) { create(:course, funding_type: 'salary') }
      let(:application_choice) { create(:application_choice, status: :offer, course_option: create(:course_option, course: fee_paying_course)) }
      let(:course_option) { create(:course_option, course: salaried_course) }
      let!(:error_message) { I18n.t('support_interface.errors.messages.funding_type_error', course: 'an offered course') }

      it 'raises a FundingTypeError if current course is fee paying and the new course is salaried' do
        expect {
          described_class.new(course_option_id: course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)
        }.to raise_error(FundingTypeError, error_message)
      end

      it 'raises a FundingType error if current course is fee paying and the new course is an apprenticeship' do
        apprenticeship = create(:course, funding_type: 'apprenticeship')
        course_option = create(:course_option, course: apprenticeship)

        expect {
          described_class.new(course_option_id: course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)
        }.to raise_error(FundingTypeError, error_message)
      end

      it 'does not raise an error for other combinations of funding types for courses' do
        course_option =  create(:course_option, course: fee_paying_course)

        expect {
          described_class.new(course_option_id: course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)
        }.not_to raise_error(FundingTypeError, error_message)
      end
    end

    context 'course full check' do
      let(:application_choice) { create(:application_choice, status: :offer) }

      it 'raises a CourseFullError if the new course has no vacancies' do
        course_option = create(:course_option, :no_vacancies, course: fee_paying_course)
        error_message = I18n.t('support_interface.errors.messages.course_full_error')

        expect {
          described_class.new(course_option_id: course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true').save(application_choice)
        }.to raise_error(CourseFullError, error_message)
      end

      it 'does not raise a CourseFullError if confirm_course_change is true' do
        course_option =  create(:course_option, :no_vacancies, course: fee_paying_course)

        expect {
          described_class.new(course_option_id: course_option.id, audit_comment: zendesk_ticket, accept_guidance: 'true', confirm_course_change: 'true').save(application_choice)
        }.not_to raise_error
      end
    end
  end
end
