module CandidateInterface
  class VolunteeringRoleForm
    include ActiveModel::Model
    include DateValidationHelper

    attr_accessor :id, :role, :organisation, :details, :working_with_children,
                  :start_date_day, :start_date_month, :start_date_year,
                  :end_date_day, :end_date_month, :end_date_year

    validates :role, :organisation, :working_with_children, presence: true

    validates :role, :organisation, length: { maximum: 60 }

    validates :start_date, date: { presence: true, future: true, month_and_year: true }
    validates :end_date, date: { future: true, month_and_year: true }, unless: :start_date_blank?
    validate :start_date_before_end_date, unless: ->(c) { %i[start_date end_date].any? { |d| c.errors.keys.include?(d) } }, if: %i[start_date end_date]

    validates :details, presence: true, word_count: { maximum: 150 }

    class << self
      def build_all_from_application(application_form)
        application_form.application_volunteering_experiences.order(created_at: :desc).map do |volunteering_role|
          new_volunteering_role_form(volunteering_role)
        end
      end

      def build_from_experience(experience)
        new_volunteering_role_form(experience)
      end

    private

      def new_volunteering_role_form(volunteering_role)
        new(
          id: volunteering_role.id,
          role: volunteering_role.role,
          organisation: volunteering_role.organisation,
          details: volunteering_role.details,
          working_with_children: volunteering_role.working_with_children,
          start_date_month: volunteering_role.start_date.month,
          start_date_year: volunteering_role.start_date.year,
          end_date_month: volunteering_role.end_date&.month || '',
          end_date_year: volunteering_role.end_date&.year || '',
        )
      end
    end

    def save(application_form)
      return false unless valid?

      application_form.application_volunteering_experiences.create!(map_attributes)
      application_form.update!(volunteering_experience: true)

      true
    end

    def update(application_form)
      return false unless valid?

      volunteering_role = application_form.application_volunteering_experiences.find(id)

      volunteering_role.update!(map_attributes)
    end

    def start_date
      valid_or_invalid_date(start_date_year, start_date_month)
    end

    def end_date
      valid_or_invalid_date(end_date_year, end_date_month)
    end

  private

    def map_attributes
      {
        role: role,
        organisation: organisation,
        details: details,
        working_with_children: ActiveModel::Type::Boolean.new.cast(working_with_children),
        start_date: start_date,
        end_date: end_date,
      }
    end

    def start_date_blank?
      month_and_year_blank?(start_date)
    end
  end
end
