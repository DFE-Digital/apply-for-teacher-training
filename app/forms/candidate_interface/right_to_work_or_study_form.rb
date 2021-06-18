module CandidateInterface
  class RightToWorkOrStudyForm
    include ActiveModel::Model

    attr_accessor :right_to_work_or_study, :right_to_work_or_study_details

    validates :right_to_work_or_study, presence: true
    validates :right_to_work_or_study_details, presence: true, if: :right_to_work_or_study?
    validates :right_to_work_or_study_details, word_count: { maximum: 200 }

    def self.build_from_application(application_form)
      new(
        right_to_work_or_study: application_form.right_to_work_or_study,
        right_to_work_or_study_details: application_form.right_to_work_or_study_details,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        right_to_work_or_study: right_to_work_or_study,
        right_to_work_or_study_details: set_right_to_work_or_study_details,
      )
    end

  private

    def right_to_work_or_study?
      right_to_work_or_study == 'yes'
    end

    def set_right_to_work_or_study_details
      right_to_work_or_study? ? right_to_work_or_study_details : nil
    end
  end
end
