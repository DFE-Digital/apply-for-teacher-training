module CandidateInterface
  module ContinuousApplications
    class DashboardComponent < ViewComponent::Base
      attr_reader :application_form

      def initialize(application_form:)
        @application_form = application_form
      end

      def application_choices
        @application_form
          .application_choices
          .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
          .includes(offer: :conditions)
          .order(created_at: :desc)
      end
    end
  end
end
