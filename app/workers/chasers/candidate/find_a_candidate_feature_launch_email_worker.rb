module Chasers
  module Candidate
    class StaggeredFindACandidateFeatureLaunchEmailWorker
      include Sidekiq::Worker

      def perform(application_form_ids)
        application_forms = FindACandidateFeatureLaunchEmailWorker.application_forms_to_send(application_form_ids)

        BatchDelivery.new(relation: application_forms, stagger_over: 1.hour, batch_size: 500).each do |batch_time, applications|
          FindACandidateFeatureLaunchEmailWorker.perform_at(batch_time, applications.pluck(:id))
        end
      end
    end

    class FindACandidateFeatureLaunchEmailWorker
      include Sidekiq::Worker

      def self.application_forms_to_send(application_form_ids)
        application_form_ids_with_sent_chaser = ChaserSent
                                                  .where(chaser_type: 'find_a_candidate_feature_launch',
                                                         chased_type: 'ApplicationForm')
                                                  .select(:chased_id)

        ApplicationForm
          .where(id: application_form_ids)
          # Filter out candidates who should not receive nudge-like emails
          # Filter out blocked and locked candidates
          .joins(:candidate).merge(::Candidate.for_marketing_or_nudge_emails)
          # Filter out application forms that have already received the chaser
          .where.not(id: application_form_ids_with_sent_chaser)
          # Filter out application forms without submitted application choices
          .where.not(submitted_at: nil)
          .distinct
      end

      def perform(application_form_ids, limit = 1000)
        return unless FeatureFlag.active?(:candidate_preferences)

        application_forms_to_send = FindACandidateFeatureLaunchEmailWorker
                                      .application_forms_to_send(application_form_ids)
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
