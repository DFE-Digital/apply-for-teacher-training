module CandidateInterface
  class WorkExperienceForm
    include ActiveModel::Model
    include DateValidationHelper

    attr_accessor :role, :organisation, :details, :working_with_children,
                  :commitment, :working_pattern,
                  :start_date_day, :start_date_month, :start_date_year,
                  :end_date_day, :end_date_month, :end_date_year, :add_another_job

    validates :role, :organisation, :details, :working_with_children,
              :commitment,
              presence: true

    validates :working_with_children, inclusion: { in: %w(true false) }

    validate :start_date_valid
    validate :end_date_valid, unless: :end_date_blank?
    validate :end_date_before_current_year_and_month, if: :end_date_valid?
    validate :start_date_before_end_date, if: :start_date_and_end_date_valid?

    validates :role, :organisation,
              length: { maximum: 60 }

    validates :details, :working_pattern,
              word_count: { maximum: 150 }

    def self.build_from_experience(work_experience)
      new(
        role: work_experience.role,
        organisation: work_experience.organisation,
        details: work_experience.details,
        commitment: work_experience.commitment,
        working_with_children: work_experience.working_with_children.to_s,
        start_date_day: work_experience.start_date.day,
        start_date_month: work_experience.start_date.month,
        start_date_year: work_experience.start_date.year,
        end_date_day: work_experience.end_date&.day || '',
        end_date_month: work_experience.end_date&.month || '',
        end_date_year: work_experience.end_date&.year || '',
        working_pattern: work_experience.working_pattern,
      )
    end

    def update(work_experience)
      return false unless valid?

      work_experience.update!(
        role: role,
        organisation: organisation,
        details: details,
        commitment: commitment,
        working_with_children: ActiveModel::Type::Boolean.new.cast(working_with_children),
        start_date: start_date,
        end_date: end_date,
        working_pattern: working_pattern,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.application_work_experiences.create!(
        role: role,
        organisation: organisation,
        details: details,
        commitment: commitment,
        working_with_children: ActiveModel::Type::Boolean.new.cast(working_with_children),
        start_date: start_date,
        end_date: end_date,
        working_pattern: working_pattern,
      )
    end

    def start_date
      valid_or_invalid_date(start_date_year, start_date_month)
    end

    def end_date
      valid_date_or_nil(end_date_year, end_date_month)
    end
  end
end
