module SupportInterface
  module ApplicationForms
    class EditGcseGradeForm
      include ActiveModel::Model

      attr_reader :gcse
      attr_accessor :grade, :constituent_subject, :audit_comment

      validates :grade, presence: true
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      delegate :application_form, :subject, to: :gcse

      def initialize(gcse, constituent_subject)
        @gcse = gcse
        @constituent_subject = constituent_subject

        super(
          grade: @gcse.grade || @gcse.constituent_grades.dig(constituent_subject, 'grade'),
        )
      end

      def save!
        if constituent_subject.present?
          @gcse.update!(
            constituent_grades: @gcse.constituent_grades
              .merge(constituent_subject => { grade: }),
            audit_comment:,
          )
        else
          @gcse.update!(
            grade:,
            audit_comment:,
          )
        end
      end
    end
  end
end
