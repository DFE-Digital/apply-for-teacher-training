require 'rails_helper'

RSpec.describe UCASMatch do
  include FactoryStubs::UCASMatch

  let(:candidate) { create(:candidate) }
  let(:course) { create(:course) }
  let(:application_form_awaiting_provider_decision) { create(:completed_application_form, candidate_id: candidate.id, application_choices_count: 1) }
  let(:course1) { application_form_awaiting_provider_decision.application_choices.first.course_option.course }
  let(:both_schemes_match) do
    { 'Scheme' => 'B',
      'Course code' => course.code.to_s,
      'Apply candidate ID' => candidate.id.to_s,
      'Provider code' => course.provider.code.to_s }
  end
  let(:ucas_match) { build_stubbed(:ucas_match) }

  before(:all) do
    define_dual_application_ucas_match_stub
  end

  describe '#action_needed?' do
    it 'returns false if ucas match has been manually resolved' do
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'manually_resolved')

      expect(ucas_match.action_needed?).to eq(false)
    end

    it 'returns false if ucas match is resolved' do
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'resolved_on_ucas')

      expect(ucas_match.action_needed?).to eq(false)
    end

    it 'returns false if initial emails were sent and we do not need to send the reminders yet' do
      initial_emails_sent_at = Time.zone.now
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'initial_emails_sent', candidate_last_contacted_at: initial_emails_sent_at)

      Timecop.travel(1.business_days.after(initial_emails_sent_at)) do
        expect(ucas_match.action_needed?).to eq(false)
      end
    end

    it 'returns true if initial emails were sent and it is time to send a reminder email' do
      ucas_match = build_stubbed(:dual_application_ucas_match, :need_to_send_reminder_emails)

      expect(ucas_match.action_needed?).to eq(true)
    end

    it 'returns false if reminder emails were sent and we do not need to request withdrawal from UCAS yet' do
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'reminder_emails_sent', candidate_last_contacted_at: Time.zone.now)

      expect(ucas_match.action_needed?).to eq(false)
    end

    it 'returns true if reminder emails were sent and it is time to request withdrawal from UCAS' do
      ucas_match = build_stubbed(:dual_application_ucas_match, :need_to_request_withdrawal_from_ucas)

      expect(ucas_match.action_needed?).to eq(true)
    end

    it 'returns false if we requested withdrawal from UCAS' do
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'ucas_withdrawal_requested', candidate_last_contacted_at: Time.zone.now)

      expect(ucas_match.action_needed?).to eq(false)
    end

    it 'returns true if there is a dual application or dual acceptance' do
      ucas_match = build_stubbed(:dual_application_ucas_match)

      expect(ucas_match.action_needed?).to eq(true)
    end

    it 'returns false if there is no dual application or dual acceptance' do
      allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(false)

      expect(ucas_match.action_needed?).to eq(false)
    end
  end

  describe '#resolved?' do
    it 'returns true if action_taken is resolved_on_apply or resolved_on_ucas' do
      ucas_match = build_stubbed(:ucas_match, action_taken: 'resolved_on_ucas')

      expect(ucas_match.resolved?).to eq(true)
    end
  end

  describe '#ready_to_resolve?' do
    it 'returns true if no further action is required and the match is not resolved' do
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'ucas_withdrawal_requested')

      expect(ucas_match.ready_to_resolve?).to eq(true)
    end

    it 'returns false if no further action is required and the match is resolved' do
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'resolved_on_ucas')

      expect(ucas_match.ready_to_resolve?).to eq(false)
    end
  end

  describe '#duplicate_applications_withdrawn_from_ucas?' do
    let(:withdrawn_match) { both_schemes_match.merge('Withdrawns' => '1') }

    it 'returns true if all duplicate applications are withdrawn from UCAS' do
      ucas_match = create(:ucas_match, matching_data: [withdrawn_match, withdrawn_match])

      expect(ucas_match.duplicate_applications_withdrawn_from_ucas?).to eq(true)
    end

    it 'returns false if there are still non withdrawn duplicate applications on UCAS' do
      non_withdrawn_match = both_schemes_match.merge('Withdrawns' => '')
      ucas_match = create(:ucas_match, matching_data: [withdrawn_match, non_withdrawn_match])

      expect(ucas_match.duplicate_applications_withdrawn_from_ucas?).to eq(false)
    end
  end

  describe '#duplicate_applications_withdrawn_from_apply?' do
    let(:application_choice) { create(:application_choice, status: 'withdrawn') }
    let(:course) { application_choice.course_option.course }

    it 'returns true if all duplicate applications are withdrawn from Apply' do
      create(:application_form, candidate_id: candidate.id,
                                application_choices: [application_choice])
      ucas_match = create(:ucas_match, matching_data: [both_schemes_match, both_schemes_match])

      expect(ucas_match.duplicate_applications_withdrawn_from_apply?).to eq(true)
    end

    it 'returns false if there are still non withdrawn duplicate applications on Apply' do
      active_application_choice = create(:application_choice, status: '')
      create(:application_form, candidate_id: candidate.id,
                                application_choices: [application_choice, active_application_choice])
      application_course = active_application_choice.course_option.course
      active_apply_match = both_schemes_match.merge({ 'Course code' => application_course.code.to_s,
                                                      'Provider code' => application_course.provider.code.to_s })
      ucas_match = create(:ucas_match, matching_data: [both_schemes_match, active_apply_match])

      expect(ucas_match.duplicate_applications_withdrawn_from_apply?).to eq(false)
    end
  end

  describe '#dual_application_or_dual_acceptance?' do
    it 'returns true if a candidate applied for the same course on both services and both applications are still in progress' do
      ucas_match = create(:ucas_match, :with_dual_application)

      expect(ucas_match.dual_application_or_dual_acceptance?).to eq(true)
    end

    it 'returns false if a candidate applied for the same course on both services but at least one of them was unsucesfull' do
      ucas_match = create(:ucas_match, :with_dual_application, ucas_status: :rejected)

      expect(ucas_match.dual_application_or_dual_acceptance?).to eq(false)
    end

    it 'returns true if application is accepted on UCAS and accepted on Apply' do
      ucas_match = create(:ucas_match, :with_multiple_acceptances)

      expect(ucas_match.dual_application_or_dual_acceptance?).to eq(true)
    end

    it 'returns false if applications on both services are in unsucesfull states' do
      application_form = create(:application_form, application_choices: [create(:application_choice, :with_rejection), create(:application_choice, :with_rejection)])
      ucas_match = create(:ucas_match, scheme: %w[D U], application_form: application_form, ucas_status: :rejected)

      expect(ucas_match.dual_application_or_dual_acceptance?).to eq(false)
    end

    it 'returns false if applications on both services are in progress' do
      course1 = application_form_awaiting_provider_decision.application_choices.first.course_option.course
      ucas_matching_data = { 'Scheme' => 'U',
                             'Provider code' => course.provider.code.to_s }
      apply_matching_data = { 'Scheme' => 'D',
                              'Course code' => course1.code.to_s,
                              'Provider code' => course1.provider.code.to_s }
      ucas_match = create(:ucas_match, matching_data: [ucas_matching_data, apply_matching_data])

      expect(ucas_match.dual_application_or_dual_acceptance?).to eq(false)
    end
  end

  describe '#application_accepted_on_ucas_and_accepted_on_apply?' do
    it 'returns true if application is accepted on both UCAS and Apply' do
      ucas_match = create(:ucas_match, :with_multiple_acceptances)

      expect(ucas_match.application_accepted_on_ucas_and_accepted_on_apply?).to eq(true)
    end
  end

  describe '#need_to_send_reminder_emails?' do
    it 'returns false if last action taken in not initial emails sent' do
      emails_sent_at = Time.zone.now
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'ucas_withdrawal_requested', candidate_last_contacted_at: emails_sent_at)

      Timecop.travel(1.business_days.after(emails_sent_at)) do
        expect(ucas_match.need_to_send_reminder_emails?).to eq(false)
      end
    end

    it 'returns false if initial emails were sent and we do not need to send the reminders yet' do
      emails_sent_at = Time.zone.now
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'initial_emails_sent', candidate_last_contacted_at: emails_sent_at)

      Timecop.travel(1.business_days.after(emails_sent_at)) do
        expect(ucas_match.need_to_send_reminder_emails?).to eq(false)
      end
    end

    it 'returns true if initial emails were sent and it is time to send a reminder email' do
      ucas_match = build_stubbed(:dual_application_ucas_match, :need_to_send_reminder_emails)

      expect(ucas_match.need_to_send_reminder_emails?).to eq(true)
    end
  end

  describe '#need_to_request_withdrawal_from_ucas?' do
    it 'returns false if last action taken in not reminder emails sent' do
      emails_sent_at = Time.zone.now
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'ucas_withdrawal_requested', candidate_last_contacted_at: emails_sent_at)

      expect(ucas_match.need_to_request_withdrawal_from_ucas?).to eq(false)
    end

    it 'returns false if reminder emails were sent and we do not need to request withdrawal from ucas yet' do
      emails_sent_at = Time.zone.now
      ucas_match = build_stubbed(:dual_application_ucas_match, action_taken: 'reminder_emails_sent', candidate_last_contacted_at: emails_sent_at)

      Timecop.travel(1.business_days.after(emails_sent_at)) do
        expect(ucas_match.need_to_request_withdrawal_from_ucas?).to eq(false)
      end
    end

    it 'returns true if reminder emails were sent and it is time to request withdrawal from ucas' do
      ucas_match = build_stubbed(:dual_application_ucas_match, :need_to_request_withdrawal_from_ucas)

      expect(ucas_match.need_to_request_withdrawal_from_ucas?).to eq(true)
    end
  end

  describe '#next_action' do
    it 'returns :initial_emails_sent if the candidate has never been contacted' do
      ucas_match = build_stubbed(:dual_application_ucas_match)

      expect(ucas_match.next_action).to eq(:initial_emails_sent)
    end

    it 'returns :reminder_emails_sent if initial emails were sent and it time to send reminder emails' do
      ucas_match = build_stubbed(:dual_application_ucas_match, :need_to_send_reminder_emails)

      expect(ucas_match.next_action).to eq(:reminder_emails_sent)
    end

    it 'returns :ucas_withdrawal_requested if reminder emails were sent and it time to request withdrawal from UCAS' do
      ucas_match = build_stubbed(:dual_application_ucas_match, :need_to_request_withdrawal_from_ucas)

      expect(ucas_match.next_action).to eq(:ucas_withdrawal_requested)
    end
  end

  describe '#requires_manual_action?' do
    it 'returns true if a support agent needs to request withdrawal from UCAS' do
      ucas_match = create(:ucas_match, :need_to_request_withdrawal_from_ucas)

      expect(ucas_match.requires_manual_action?).to eq(true)
    end

    it 'returns false if the next action is automated' do
      ucas_match = create(:ucas_match, :need_to_send_reminder_emails)

      expect(ucas_match.requires_manual_action?).to eq(false)
    end
  end

  describe '#last_action' do
    it 'returns nil if no action was taken' do
      expect(ucas_match.last_action).to eq(nil)
    end

    it 'returns :initial_emails_sent if initial emails were sent' do
      ucas_match = create(:ucas_match, action_taken: 'initial_emails_sent')

      expect(ucas_match.last_action).to eq(:initial_emails_sent)
    end

    it 'returns :reminder_emails_sent if reminder emails were sent' do
      ucas_match = create(:ucas_match, action_taken: 'reminder_emails_sent')

      expect(ucas_match.last_action).to eq(:reminder_emails_sent)
    end

    it 'returns :ucas_withdrawal_requested if ucas withdrawal was requested' do
      ucas_match = create(:ucas_match, action_taken: 'ucas_withdrawal_requested')

      expect(ucas_match.last_action).to eq(:ucas_withdrawal_requested)
    end

    it 'returns :resolved_on_apply if the match was resolved on apply' do
      ucas_match = create(:ucas_match, action_taken: 'resolved_on_apply')

      expect(ucas_match.last_action).to eq(:resolved_on_apply)
    end

    it 'returns :resolved_on_ucas if the match was resolved on ucas' do
      ucas_match = create(:ucas_match, action_taken: 'resolved_on_ucas')

      expect(ucas_match.last_action).to eq(:resolved_on_ucas)
    end
  end

  describe '#ucas_matched_applications_on_both_services' do
    it 'returns applications for the same course that exist on both services' do
      matched_application = instance_double(UCASMatchedApplication, both_scheme?: true, application_choice: :application_choice)
      allow(ucas_match).to receive(:ucas_matched_applications).and_return([matched_application])

      expect(ucas_match.application_choices_for_same_course_on_both_services).to eq([:application_choice])
    end
  end

  describe '#application_for_the_same_course_in_progress_on_both_services?' do
    it 'returns true if candidate has application for the same course in progress on both UCAS and Apply' do
      ucas_match = create(:ucas_match, :with_dual_application)

      expect(ucas_match.application_for_the_same_course_in_progress_on_both_services?).to eq(true)
    end

    it 'returns false if dual application is not in progress on Apply' do
      application_choice = create(:application_choice, :with_rejection)
      ucas_match = create(:ucas_match,
                          scheme: %w[B],
                          application_form: application_choice.application_form)

      expect(ucas_match.application_for_the_same_course_in_progress_on_both_services?).to eq(false)
    end

    it 'returns false if dual application is not in progress on UCAS' do
      ucas_match = create(:ucas_match,
                          scheme: %w[B],
                          ucas_status: :withdrawn)

      expect(ucas_match.application_for_the_same_course_in_progress_on_both_services?).to eq(false)
    end

    it 'returns false if there is no dual application' do
      ucas_match = create(:ucas_match, scheme: %w[D])

      expect(ucas_match.application_for_the_same_course_in_progress_on_both_services?).to eq(false)
    end
  end

  describe '#calculate_action_date' do
    it 'returns the date when candidate has to withdraw one of their dual applications or acceptances by' do
      expect(ucas_match.calculate_action_date(:ucas_match_candidate_withdrawal_request, Time.zone.local(2020, 11, 16))).to eq(Date.new(2020, 11, 30))
    end

    it 'returns the date when a reminder email has to be sent to a candidate' do
      expect(ucas_match.calculate_action_date(:ucas_match_candidate_withdrawal_request_reminder, Time.zone.local(2020, 11, 16))).to eq(Date.new(2020, 11, 23))
    end

    it 'returns the date when UCAS will be asked to remove duplicate application or acceptances' do
      expect(ucas_match.calculate_action_date(:ucas_match_ucas_withdrawal_request, Time.zone.local(2020, 11, 16))).to eq(Date.new(2020, 11, 23))
    end
  end
end
