module CandidateInterface
  class ApplicationFeedbackForm
    include ActiveModel::Model

    attr_accessor :issues, :section, :path, :page_title, :id_in_path, :does_not_understand_section,
                  :need_more_information, :answer_does_not_fit_format, :other_feedback,
                  :consent_to_be_contacted

    validates :issues, :section, :path, :page_title, presence: true, on: :save

    validates :consent_to_be_contacted, presence: true, on: :update

    validate :path_is_valid, if: -> { path.present? }

    def save(application_form)
      return false unless valid?(:save)

      application_form.application_feedback.create!(
        issues: has_issues?,
        section: section,
        path: path,
        page_title: page_title,
        id_in_path: id_in_path,
      )
    end

    def update(application_feedback)
      return false unless valid?(:update)

      application_feedback.update!(
        does_not_understand_section: does_not_understand_section ? true : false,
        need_more_information: need_more_information ? true : false,
        answer_does_not_fit_format: answer_does_not_fit_format ? true : false,
        other_feedback: other_feedback,
        consent_to_be_contacted: consent_to_be_contacted == 'true',
      )
    end

    def has_issues?
      issues == 'true'
    end

  private

    def path_is_valid
      errors.add(:path, :invalid) if valid_paths.exclude?(path)
    end

    def valid_paths
      Rails.application.routes.named_routes.helper_names
    end
  end
end
