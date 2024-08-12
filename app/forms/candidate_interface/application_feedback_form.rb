module CandidateInterface
  class ApplicationFeedbackForm
    include ActiveModel::Model

    attr_accessor :path, :page_title, :original_controller, :feedback,
                  :consent_to_be_contacted

    validates :path, :page_title, :feedback, :consent_to_be_contacted, presence: true

    validate :path_is_valid, if: -> { path.present? }

    def save(application_form)
      return false unless valid?

      application_form.application_feedback.create!(
        path:,
        page_title:,
        feedback:,
        consent_to_be_contacted: consent_to_be_contacted == 'true',
      )
    end

    def section_name
      top_controller = original_controller.split('/')[1]

      case top_controller
      when 'references'
        'the references'
      when 'degrees', 'gcse', 'other_qualifications'
        'the qualifications'
      when 'personal_statement'
        'the personal statement'
      else
        'this'
      end
    end

  private

    def path_is_valid
      errors.add(:path, :invalid) if Rails.application.routes.recognize_path(path)[:controller] == 'errors'
    end
  end
end
