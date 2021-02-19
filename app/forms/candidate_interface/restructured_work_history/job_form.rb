module CandidateInterface
  module RestructuredWorkHistory
    class JobForm
      include ActiveModel::Model
      include DateValidationHelper

      attr_accessor :role,
                    :organisation,
                    :commitment,
                    :start_date_day,
                    :start_date_month,
                    :start_date_year,
                    :start_date_unknown,
                    :currently_working,
                    :end_date_day,
                    :end_date_month,
                    :end_date_year,
                    :end_date_unknown,
                    :relevant_skills

      validates :organisation,
                :role,
                :commitment,
                :currently_working,
                :relevant_skills,
                presence: true
      validates :role, :organisation, length: { maximum: 60 }
      validates :start_date_unknown, inclusion: { in: %w[true false] }
      validates :end_date_unknown, inclusion: { in: %w[true false] }
      validates :currently_working, inclusion: { in: %w[true false] }
      validates :relevant_skills, inclusion: { in: %w[true false] }

      validates :start_date, date: { future: true, month_and_year: true, presence: true }
      validates :end_date, date: { future: true, month_and_year: true, presence: true }, if: :not_currently_employed_in_this_role?
      validate :start_date_before_end_date, unless: ->(c) { %i[start_date end_date].any? { |d| c.errors.keys.include?(d) } }

      def self.build_form(job)
        new(
          role: job.role,
          organisation: job.organisation,
          commitment: job.commitment,
          start_date_day: job.start_date&.day,
          start_date_month: job.start_date&.month,
          start_date_year: job.start_date&.year,
          start_date_unknown: job.start_date_unknown,
          end_date_day: job.end_date&.day || '',
          end_date_month: job.end_date&.month || '',
          end_date_year: job.end_date&.year || '',
          end_date_unknown: job.end_date_unknown,
          currently_working: job.currently_working.to_s,
          relevant_skills: job.relevant_skills.to_s,
        )
      end

      def update(job)
        return false unless valid?

        job.update!(
          role: role,
          organisation: organisation,
          commitment: commitment,
          start_date: start_date,
          end_date: not_currently_employed_in_this_role? ? end_date : nil,
          start_date_unknown: start_date_unknown,
          end_date_unknown: end_date_unknown,
          currently_working: currently_working,
          relevant_skills: relevant_skills,
          details: set_details_field,
        )
      end

      def save(application_form)
        return false unless valid?

        application_form.application_work_experiences.create!(
          role: role,
          organisation: organisation,
          commitment: commitment,
          start_date: start_date,
          end_date: end_date,
          start_date_unknown: start_date_unknown,
          end_date_unknown: end_date_unknown,
          currently_working: currently_working,
          relevant_skills: relevant_skills,
          details: set_details_field,
        )
      end

      def start_date
        valid_or_invalid_date(start_date_year, start_date_month)
      end

      def end_date
        valid_or_invalid_date(end_date_year, end_date_month)
      end

      def not_currently_employed_in_this_role?
        currently_working == 'false'
      end

      def cast_booleans
        self.start_date_unknown = ActiveModel::Type::Boolean.new.cast(start_date_unknown)
        self.end_date_unknown = ActiveModel::Type::Boolean.new.cast(end_date_unknown)
        self.currently_working = ActiveModel::Type::Boolean.new.cast(currently_working)
        self.relevant_skills = ActiveModel::Type::Boolean.new.cast(relevant_skills)
      end

    private

      def set_details_field
        if ActiveModel::Type::Boolean.new.cast(relevant_skills)
          'I used skills relevant to teaching in this job.'
        else
          'I did not use skills relevant to teaching in this job.'
        end
      end
    end
  end
end
