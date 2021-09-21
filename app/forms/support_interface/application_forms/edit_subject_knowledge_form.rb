module SupportInterface
  module ApplicationForms
    class EditSubjectKnowledgeForm
      include ActiveModel::Model

      attr_accessor :subject_knowledge, :audit_comment

      validates :subject_knowledge,
                word_count: { maximum: 400 },
                presence: true

      validates :audit_comment, presence: true

      def self.build_from_application(application_form)
        new(
          subject_knowledge: application_form.subject_knowledge,
        )
      end

      def save(application_form)
        return false unless valid?

        application_form.update!(
          subject_knowledge: subject_knowledge,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
