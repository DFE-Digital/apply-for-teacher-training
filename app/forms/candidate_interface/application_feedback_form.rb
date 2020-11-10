module CandidateInterface
  class ApplicationFeedbackForm
    include ActiveModel::Model

    attr_accessor :issues, :section, :path, :page_title, :id_in_path

    validates :issues, :section, :path, :page_title, presence: true

    validate :path_is_valid, if: -> { path.present? }

    def save(application_form)
      return false unless valid?

      application_form.application_feedback.create!(
        issues: has_issues?,
        section: section,
        path: path,
        page_title: page_title,
        id_in_path: id_in_path,
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
