module CandidateInterface
  class ImmigrationRightToWorkForm
    include ActiveModel::Model

    attr_accessor :right_to_work_or_study, :right_to_work_or_study_details

    validates :right_to_work_or_study, presence: true

    def self.build_from_application(application_form)
      new(
        right_to_work_or_study: application_form.right_to_work_or_study,
      )
    end

    def save(application_form)
      return false unless valid?

      if right_to_work_or_study?
      application_form.update(
        right_to_work_or_study: right_to_work_or_study,
      )
      else
        application_form.update(
        right_to_work_or_study: right_to_work_or_study,
        right_to_work_or_study_details: nil,
        immigration_status: nil,
        )
      end
    end

    def right_to_work_or_study?
      right_to_work_or_study == 'yes'
    end
  end
end
