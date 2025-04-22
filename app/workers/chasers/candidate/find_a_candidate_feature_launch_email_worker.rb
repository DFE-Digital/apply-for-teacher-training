module Chasers
  module Candidate
    class FindACandidateFeatureLaunchEmailWorker
      include Sidekiq::Worker

      def perform(application_form_ids, limit = 1000)
        return unless FeatureFlag.active?(:candidate_preferences)

        application_form_ids_with_sent_chaser = ChaserSent
                                                  .where(chaser_type: 'find_a_candidate_feature_launch',
                                                         chased_type: 'ApplicationForm')
                                                  .select(:chased_id)

        application_forms_to_send = ApplicationForm
                                      .where(id: application_form_ids)
                                      # Tier 1 & 2 application forms
                                      .where(id: Pool::Candidates.application_forms_eligible_for_pool)
                                      # Filter out candidates who should not receive nudge-like emails
                                      # Filter out blocked and locked candidates
                                      .joins(:candidate)
                                      .merge(::Candidate.for_marketing_or_nudge_emails)
                                      # Filter out application forms that have already received the chaser
                                      .where.not(id: application_form_ids_with_sent_chaser)
                                      # Filter out application forms without submitted application choices
                                      .where.not(submitted_at: nil)
                                      .distinct
                                      .limit(limit)

        application_forms_to_send.in_batches do |application_forms|
          application_forms.each do |application_form|
            ChaserSent.create!(chased: application_form, chaser_type: 'find_a_candidate_feature_launch')
            CandidateMailer.find_a_candidate_feature_launch_email(application_form).deliver_later
          end
        end
      end
    end
  end
end
