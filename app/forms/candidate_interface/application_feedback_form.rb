module CandidateInterface
  class ApplicationFeedbackForm
    include ActiveModel::Model

    attr_accessor :path, :page_title, :original_controller, :does_not_understand_section,
                  :need_more_information, :answer_does_not_fit_format, :other_feedback,
                  :consent_to_be_contacted

    validates :other_feedback, presence: true
    validates :path, :page_title, :consent_to_be_contacted, presence: true

    validate :path_is_valid, if: -> { path.present? }

    def save(application_form)
      set_booleans

      return false unless valid?

      application_form.application_feedback.create!(
        path: path,
        page_title: page_title,
        does_not_understand_section: does_not_understand_section,
        need_more_information: need_more_information,
        answer_does_not_fit_format: answer_does_not_fit_format,
        other_feedback: other_feedback,
        consent_to_be_contacted: consent_to_be_contacted == 'true',
      )
    end

    def set_booleans
      @does_not_understand_section = @does_not_understand_section.present?
      @need_more_information = @need_more_information.present?
      @answer_does_not_fit_format = @answer_does_not_fit_format.present?
    end

    def section_name
      top_controller = original_controller.split('/')[1]

      case top_controller
      when 'references'
        'the references'
      when 'degrees', 'gcse', 'other_qualifications'
        'the qualifications'
      when 'personal_statement'
        'the personal statement and interview'
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
