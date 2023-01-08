module SupportInterface
  module ApplicationForms
    class EditGcseGradeForm
      include ActiveModel::Model

      attr_reader :gcse
      attr_accessor :grade, :constituent, :index, :audit_comment

      validates :grade, presence: true
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      delegate :application_form, :subject, to: :gcse

      def initialize(gcse, constituent, index)
        @gcse = gcse
        @constituent = constituent
        @index = index

        super(
          grade: @gcse.grade || @gcse.constituent_grades.values[index.to_i]['grade'],
        )
      end

      def save!
        if ActiveModel::Type::Boolean.new.cast(constituent)
          constituent_grades = @gcse.constituent_grades
          constituent_grades.values[index.to_i]['grade'] = grade

          @gcse.update!(
            constituent_grades: constituent_grades,
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
