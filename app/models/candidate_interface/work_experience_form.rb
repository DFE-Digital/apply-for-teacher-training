module CandidateInterface
  class WorkExperienceForm
    include ActiveModel::Model

    attr_accessor :role, :organisation, :details, :working_with_children,
                  :commitment, :start_date_month, :start_date_year,
                  :end_date_month, :end_date_year

    validates :role, :organisation, :details, :working_with_children,
              :commitment, :start_date_month, :start_date_year,
              presence: true

    validates :working_with_children, inclusion: { in: %w(true false) }

    def save(application_form)
      return false unless valid?

      application_form.application_work_experiences.create!(
        role: role,
        organisation: organisation,
        details: details,
        commitment: commitment,
        working_with_children: ActiveModel::Type::Boolean.new.cast(working_with_children),
        start_date: Date.new(start_date_year.to_i, start_date_month.to_i),
        end_date: Date.new(end_date_year.to_i, end_date_month.to_i),
      )
    end
  end
end
