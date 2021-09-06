module CandidateInterface
  class ImmigrationRightToWorkForm
    include ActiveModel::Model

    attr_accessor :immigration_right_to_work

    validates :immigration_right_to_work, presence: true

    def self.build_from_application(application_form)
      new(
        immigration_right_to_work: application_form.immigration_right_to_work,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        immigration_right_to_work: immigration_right_to_work,
      )
    end

  private

    def right_to_work_or_study?
      immigration_right_to_work
    end

    def set_right_to_work_or_study_details
      right_to_work_or_study? ? right_to_work_or_study_details : nil
    end
  end
end
