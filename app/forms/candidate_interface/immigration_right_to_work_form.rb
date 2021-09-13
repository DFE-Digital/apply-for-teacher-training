module CandidateInterface
  class ImmigrationRightToWorkForm
    include ActiveModel::Model

    attr_accessor :immigration_right_to_work

    validates :immigration_right_to_work, inclusion: { in: [true, false, 'true', 'false'] }

    def self.build_from_application(application_form)
      new(
        immigration_right_to_work: application_form.immigration_right_to_work,
      )
    end

    def save(application_form)
      return false unless valid?

      if right_to_work_or_study? == true
        application_form.update(
          immigration_right_to_work: immigration_right_to_work,
          immigration_route: nil,
          immigration_route_details: nil,
        )
      else
        application_form.update(
          immigration_right_to_work: immigration_right_to_work,
          immigration_status: nil,
          immigration_status_details: nil,
          immigration_entry_date: nil,
        )
      end
    end

    def right_to_work_or_study?
      ActiveModel::Type::Boolean.new.cast(immigration_right_to_work)
    end

  private

    def set_right_to_work_or_study_details
      right_to_work_or_study? ? right_to_work_or_study_details : nil
    end
  end
end
