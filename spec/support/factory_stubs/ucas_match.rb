module FactoryStubs
  module UCASMatch

    def define_dual_application_ucas_match_stub
      FactoryBot.define do
        factory :dual_application_ucas_match, class: 'UCASMatch' do
          trait :need_to_send_reminder_emails do
            action_taken { 'initial_emails_sent' }
            candidate_last_contacted_at { 5.business_days.before(Time.zone.now) }
          end

          trait :need_to_request_withdrawal_from_ucas do
            action_taken { 'reminder_emails_sent' }
            candidate_last_contacted_at { 5.business_days.before(Time.zone.now) }
          end

          after(:stub) do |ucas_match, _|
            allow(ucas_match).to receive(:dual_application_or_dual_acceptance?).and_return(true)
          end
        end
      end
    end
  end
end
