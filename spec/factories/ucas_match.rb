FactoryBot.define do
  factory :ucas_match do
    candidate { application_form.candidate }
    matching_data { nil }
    recruitment_cycle_year { application_form.recruitment_cycle_year }
    transient do
      application_form { create(:completed_application_form, submitted_application_choices_count: 1) }
      ucas_status { nil }
      scheme { rand(1..3).times.map { %w[U D B].sample } }
    end

    after(:build) do |ucas_match, evaluator|
      if ucas_match.matching_data.nil?
        ucas_statuses = {
          rejected: { 'Rejects' => '1' },
          withdrawn: { 'Withdrawns' => '1' },
          declined: { 'Declined offers' => '1' },
          offer: { 'Offers' => '1' },
          pending_conditions: { 'Offers' => '1', 'Conditional firm' => '1' },
          recruited: { 'Offers' => '1', 'Unconditional firm' => '1' },
          awaiting_provider_decision: { 'Applications' => '1' },
        }.freeze

        candidate_id = ucas_match.candidate.id.to_s
        shared_data = {
          'Apply candidate ID' => candidate_id,
          'Trackable applicant key' => "ABC#{candidate_id}UCAS",
        }

        # Don't generate Apply's ApplicationChoice for an application on UCAS
        if evaluator.scheme&.include?('U')
          ucas_applications_data = evaluator.scheme.count('U').times.map do
            status_on_ucas = ucas_statuses[evaluator.ucas_status] || ucas_statuses[%i[rejected withdrawn declined offer awaiting_provider_decision].sample]
            provider = create(:provider)
            { 'Scheme' => 'U',
              'Course code' => Faker::Alphanumeric.alphanumeric(number: 4, min_alpha: 1).upcase,
              'Provider code' => provider.code }.merge!(shared_data).merge!(status_on_ucas)
          end
          evaluator.scheme.delete('U')
        end

        apply_applications_data = evaluator.application_form.application_choices.map do |application_choice|
          scheme = evaluator.scheme.pop || 'B'
          data = {
            'Scheme' => scheme,
            'Course code' => application_choice.current_course_option.course.code.to_s,
            'Provider code' => application_choice.current_course.provider.code.to_s,
          }.merge!(shared_data)

          if scheme == 'B'
            status_on_ucas = ucas_statuses[evaluator.ucas_status] || ucas_statuses[%i[rejected withdrawn declined offer awaiting_provider_decision].sample]
            data.merge!(status_on_ucas)
          end
          data
        end

        ucas_match.matching_data = [ucas_applications_data, apply_applications_data].flatten.compact
      end
    end

    trait :with_dual_application do
      scheme { %w[B] }
      application_form { create(:completed_application_form, application_choices: [create(:submitted_application_choice)]) }
      ucas_status { :awaiting_provider_decision }
    end

    trait :with_multiple_acceptances do
      scheme { %w[U D] }
      application_form do
        create(:completed_application_form, application_choices: [create(:application_choice, :with_accepted_offer)])
      end
      ucas_status { :pending_conditions }
    end

    trait :need_to_send_reminder_emails do
      action_taken  { 'initial_emails_sent' }
      candidate_last_contacted_at { 5.business_days.before(Time.zone.now) }
    end

    trait :need_to_request_withdrawal_from_ucas do
      action_taken { 'reminder_emails_sent' }
      candidate_last_contacted_at { 5.business_days.before(Time.zone.now) }
    end
  end
end
