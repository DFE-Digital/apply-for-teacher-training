module CandidateInterface
  class ApplicationFeedbackForm
    include ActiveModel::Model

    attr_accessor :section, :path, :page_title, :does_not_understand_section,
                  :need_more_information, :answer_does_not_fit_format, :other_feedback,
                  :consent_to_be_contacted

    validates :section, :path, :page_title, :consent_to_be_contacted, presence: true

    validate :path_is_valid, if: -> { path.present? }
    validate :section_is_valid, if: -> { section.present? }

    VALID_SECTIONS = %w[
      application_references
      degrees
      gcses
      other_qualifications
      personal_statement
      subject_knowledge
    ].freeze

    def save(application_form)
      return false unless valid?

      application_form.application_feedback.create!(
        section: section,
        path: path,
        page_title: page_title,
        does_not_understand_section: does_not_understand_section ? true : false,
        need_more_information: need_more_information ? true : false,
        answer_does_not_fit_format: answer_does_not_fit_format ? true : false,
        other_feedback: other_feedback,
        consent_to_be_contacted: consent_to_be_contacted == 'true',
      )
    end

  private

    def path_is_valid
      errors.add(:path, :invalid) if valid_paths.exclude?(path)
    end

    def valid_paths
      Rails.application.routes.named_routes.helper_names
    end

    def section_is_valid
      errors.add(:section, :invalid) if VALID_SECTIONS.exclude?(section)
    end
  end
end
