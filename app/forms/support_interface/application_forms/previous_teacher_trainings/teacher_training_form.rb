module SupportInterface
  module ApplicationForms
    module PreviousTeacherTrainings
      class TeacherTrainingForm
        include ActiveModel::Model
        include DateValidationHelper

        attr_accessor :provider_name, :start_date_day, :start_date_month, :start_date_year,
                      :end_date_day, :end_date_month, :end_date_year, :details, :audit_comment, :previous_teacher_training

        validates :provider_name, presence: true, length: { maximum: 100 }
        validates :started_at, date: { month_and_year: true, presence: true, past: true, before: :ended_at }
        validates :ended_at, date: { month_and_year: true, presence: true, past: true }
        validates :details, presence: true, word_count: { maximum: 200 }
        validates :audit_comment, presence: true

        def initialize(previous_teacher_training = nil)
          return unless previous_teacher_training

          @previous_teacher_training = previous_teacher_training
          @provider_name = previous_teacher_training.provider_name
          @start_date_month = previous_teacher_training.started_at&.month
          @start_date_year = previous_teacher_training.started_at&.year
          @end_date_month = previous_teacher_training.ended_at&.month
          @end_date_year = previous_teacher_training.ended_at&.year
          @details = previous_teacher_training.details
        end

        def providers
          @providers ||= Provider.all
        end

        def save
          return false unless valid?

          previous_teacher_training.started = 'yes'
          previous_teacher_training.provider_name = provider_name
          previous_teacher_training.provider_id = Provider.find_by(name: provider_name)&.id
          previous_teacher_training.started_at = started_at
          previous_teacher_training.ended_at = ended_at
          previous_teacher_training.details = details

          previous_teacher_training.audit_comment = audit_comment
          previous_teacher_training.save!
          previous_teacher_training.make_published

          true
        end

        def started_at
          valid_or_invalid_date(start_date_year, start_date_month)
        end

        def ended_at
          valid_or_invalid_date(end_date_year, end_date_month)
        end
      end
    end
  end
end
