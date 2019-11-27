module SupportInterface
  class ApplicationCommentForm
    include ActiveModel::Model

    attr_accessor :comment

    validates :comment, presence: true

    def save(application_form)
      return false unless valid?

      application_form.update(
        audit_comment: comment,
      )
    end
  end
end
