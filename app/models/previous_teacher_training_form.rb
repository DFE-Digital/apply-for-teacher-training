class PreviousTeacherTrainingForm < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :application_form

  enum :choice, {
    yes: 'yes',
    no: 'no',
  }, prefix: true

  def reviewable?
    return true if choice_yes? && [provider_name, started_at, details].all?(&:present?)
    return true if choice_no? && [provider_name, started_at, details].all?(&:nil?)

    false
  end

  class Start < PreviousTeacherTrainingForm
    Choice = Data.define(:value, :name)

    validates :choice, presence: true

    def choices_to_select
      PreviousTeacherTrainingForm.choices.map do |_, value|
        Choice.new(value: value, name: value.capitalize)
      end
    end

    def save
      if choice_no?
        # Add new columns here
        self.provider_name = nil
        self.started_at = nil
        self.ended_at = nil
        self.details = nil
      end

      super
    end

    def back_path(params)
      if params[:return_to] == 'review' && reviewable?
        candidate_interface_previous_teacher_training_review_path
      end
    end
  end

  class Name < PreviousTeacherTrainingForm
    validates :provider_name, presence: true

    def providers
      @providers ||= GetAvailableProviders.call
    end
  end

  class Dates < PreviousTeacherTrainingForm
    include DateValidationHelper

    attr_accessor :start_date_day, :start_date_month, :start_date_year,
                  :end_date_day, :end_date_month, :end_date_year

    validates :started_at, date: { month_and_year: true, presence: true, future: true, before: :ended_at }
    validates :ended_at, date: { month_and_year: true, future: true }

    after_find :set_form_attributes

    def set_form_attributes
      self.start_date_month = attributes['started_at']&.month
      self.start_date_year = attributes['started_at']&.year
      self.end_date_month = attributes['ended_at']&.month
      self.end_date_year = attributes['ended_at']&.year
    end

    def save
      assign_attributes(started_at:, ended_at:)
      super
    end

    def started_at
      valid_or_invalid_date(start_date_year, start_date_month)
    end

    def ended_at
      date = valid_or_invalid_date(end_date_year, end_date_month)

      month_and_year_blank?(date) ? nil : date
    end
  end

  class Details < PreviousTeacherTrainingForm
    validates :details, presence: true, word_count: { maximum: 500 }
  end

  class Review < PreviousTeacherTrainingForm
    attr_accessor :completed

    validates :completed, presence: true
    validates :completed, inclusion: { in: %w[true false] }

    def formatted_dates
      result = "From #{started_at.to_fs(:month_and_year)}"
      if ended_at.present?
        result += " to #{ended_at.to_fs(:month_and_year)}"
      end

      result
    end

    def save
      return false if invalid?

      ActiveRecord::Base.transaction do
        PreviousTeacherTraining.destroy_all
        PreviousTeacherTraining.create!(
          choice:,
          application_form:,
          provider_name:,
          started_at:,
          ended_at:,
          details:,
        )
        application_form.update(previous_teacher_training_completed: completed)
        # test if this returns error on create!
        delete
      end

      true
    end
  end
end
