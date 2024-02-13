module CandidateInterface
  module ContinuousApplications
    class DashboardComponent < ViewComponent::Base
      attr_reader :application_form, :application_choices

      ApplicationType = Struct.new(:text, :link, :active?, keyword_init: true)

      def initialize(application_form:, application_choices:)
        @application_form = application_form
        @application_choices = application_choices
        @application_types = %w[all offers_received draft unsuccessful in_progress withdraw declined]
      end

      def tabs
        @application_types.map do |application_type|
          ApplicationType.new(text: I18n.t("candidate_interface.application_tabs.#{application_type}"), link: candidate_interface_continuous_applications_choices_path(application_type:), active?: active_tab?(application_type))
        end
      end

      def active_tab?(application_type)
        application_type == params[:application_type]
      end
    end
  end
end
