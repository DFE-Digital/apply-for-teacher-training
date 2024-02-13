module CandidateInterface
  module ContinuousApplications
    class DashboardComponent < ViewComponent::Base
      attr_reader :application_form, :application_choices

      ApplicationTab = Struct.new(:text, :link, :active?, keyword_init: true)

      def initialize(application_form:, application_choices:)
        @application_form = application_form
        @application_choices = application_choices
        @application_tabs = %w[all offers_received draft unsuccessful in_progress withdraw declined]
      end

      def tabs
        all_tabs.values_at(*application_choices_groups)
      end

      def current_tab_application_choices
        return @application_choices if all_applications? || @application_tabs.exclude?(params[:application_type])

        @application_choices.select { |ac| ac.application_choices_group == @application_tabs.index(params[:application_type]) }
      end

    private

      def active_tab?(application_type)
        (all_applications? && application_type == 'all') || application_type == params[:application_type]
      end

      def all_tabs
        @application_tabs.map do |application_type|
          ApplicationTab.new(text: I18n.t("candidate_interface.application_tabs.#{application_type}"), link: candidate_interface_continuous_applications_choices_path(application_type:), active?: active_tab?(application_type))
        end
      end

      def application_choices_groups
        [@application_tabs.index('all'), @application_choices.map(&:application_choices_group)].flatten.uniq
      end

      def all_applications?
        params[:application_type].blank? ||
          params[:application_type] == 'all' ||
            @application_tabs.exclude?(params[:application_type])
      end
    end
  end
end
