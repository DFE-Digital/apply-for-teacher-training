module SupportInterface
  module ApplicationForms
    class CourseSearchForm
      include ActiveModel::Model
      include ValidationUtils

      attr_accessor :course_code, :application_form_id

      validates :course_code, presence: true

      def applicant_name
        application_form.full_name
      end

    private

      def application_form
        @application_form ||= ApplicationForm.find(application_form_id)
      end
    end
  end
end
