require 'rails_helper'

RSpec.describe SendNewOfferEmailToCandidate do
  describe '#call' do
    def setup_application
      @candidate = build_stubbed(:candidate)
      @application_form = build_stubbed(
        :application_form,
        support_reference: 'SUPPORT-REFERENCE',
        candidate: @candidate,
        first_name: 'Bob',
      )
      course_option = build_stubbed(:course_option)
      @application_choice = @application_form.application_choices.build(
        id: 123,
        application_form: @application_form,
        course_option: course_option,
        status: :offer,
      )
    end

    context 'when there is a single offer' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_single_offer).and_return(mail)
        setup_application
      end

      it 'sends new offer email for single offer case' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_single_offer).with(@application_choice)
      end

      it 'audits the new offer email', with_audited: true do
        expected_comment = 'blah'
        pending 'not implemented yet'
        expect(application_choice.application_form.audits.last.comment).to eq(expected_comment)
      end
    end

    context 'when there are multiple offers' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_multiple_offers).and_return(mail)
        setup_application
        other_course_option = build_stubbed(:course_option)
        @other_application_choice = @application_form.application_choices.build(
          id: 456,
          application_form: @application_form,
          course_option: other_course_option,
          status: :offer,
        )
        @application_form.id = nil
        @application_form.application_choices = [@application_choice, @other_application_choice]
      end

      it 'sends new offer email for multiple offers case' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_multiple_offers).with(@application_choice)
      end

      it 'audits the new offer email', with_audited: true do
        expected_comment = 'blah'
        pending 'not implemented yet'
        expect(application_choice.application_form.audits.last.comment).to eq(expected_comment)
      end
    end

    context 'when there are decisions pending' do
      before do
        mail = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to receive(:new_offer_decisions_pending).and_return(mail)
        setup_application
        other_course_option = build_stubbed(:course_option)
        @other_application_choice = @application_form.application_choices.build(
          id: 456,
          application_form: @application_form,
          course_option: other_course_option,
          status: :awaiting_provider_decision,
        )
        @application_form.id = nil
        @application_form.application_choices = [@application_choice, @other_application_choice]
      end

      it 'sends new offer email for pending decision case' do
        described_class.new(application_choice: @application_choice).call
        expect(CandidateMailer).to have_received(:new_offer_decisions_pending).with(@application_choice)
      end

      it 'audits the new offer email', with_audited: true do
        expected_comment = 'blah'
        pending 'not implemented yet'
        expect(application_choice.application_form.audits.last.comment).to eq(expected_comment)
      end
    end
  end
end
