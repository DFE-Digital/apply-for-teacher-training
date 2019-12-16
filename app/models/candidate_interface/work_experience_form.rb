module CandidateInterface
  class WorkExperienceForm
    include ActiveModel::Model

    attr_accessor :role, :organisation, :details, :working_with_children,
                  :commitment,
                  :start_date_day, :start_date_month, :start_date_year,
                  :end_date_day, :end_date_month, :end_date_year

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

    validates :details,
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
      )
    end

    def start_date
      valid_date_or_nil(start_date_year, start_date_month)
    end

    def end_date
      valid_date_or_nil(end_date_year, end_date_month)
    end

  private

    def valid_date_or_nil(year, month)
      date_args = [year, month, 1].map(&:to_i)
      Date.new(*date_args) if year.present? && Date.valid_date?(*date_args)
    end

    def end_date_blank?
      end_date_year.blank? && end_date_month.blank?
    end

    def end_date_valid
      errors.add(:end_date, :invalid) unless end_date
    end

    def start_date_valid
      errors.add(:start_date, :invalid) unless start_date
    end

    def start_date_before_end_date
      errors.add(:start_date, :before) unless start_date <= end_date
    end

    def end_date_before_current_year_and_month
      if end_date.year > Date.today.year || \
          end_date.year == Date.today.year && end_date.month > Date.today.month
        errors.add(:end_date, :in_the_future)
      end
    end

    def start_date_and_end_date_valid?
      end_date && start_date
    end

    def end_date_valid?
      end_date
    end
  end
end
