module CandidateInterface
  module ContinuousApplications
    class DashboardComponent < ViewComponent::Base
      attr_reader :application_form

      def initialize(application_form:)
        @application_form = application_form
      end

      def application_choices
        CandidateInterface::SortApplicationChoices.call(
          application_choices:
            @application_form
              .application_choices
              .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
              .includes(offer: :conditions),
        )
      end

      def group_header(application_choice)
        t("candidate_interface.sort_application_choices.#{application_choice.application_choices_group.humanize}")
      end
    end
  end
end
