module CandidateInterface
  module ContinuousApplications
    class ApplicationChoiceListComponent < ViewComponent::Base
      attr_reader :application_form, :application_choices

      ApplicationTab = Struct.new(:text, :link, :active?, keyword_init: true)

      def initialize(application_form:, application_choices:)
        @application_form = application_form
        @application_choices = application_choices
        @application_tabs = %w[all offers_received draft unsuccessful in_progress withdraw declined]
      end

      def render?
        @application_choices.present?
      end

      def tabs
        all_tabs.values_at(*application_choices_groups)
      end

      def current_tab_application_choices
        return @application_choices if all_applications?

        @application_choices.select do |application_choice|
          application_choice.application_choices_group == @application_tabs.index(params[:application_choices_group])
        end
      end

    private

      def active_tab?(application_choices_group)
        (all_applications? && application_choices_group == 'all') || application_choices_group == params[:application_choices_group]
      end

      def all_tabs
        @application_tabs.map do |application_tab|
          ApplicationTab.new(
            text: I18n.t("candidate_interface.application_tabs.#{application_tab}"),
            link: candidate_interface_continuous_applications_choices_path(application_choices_group: application_tab),
            active?: active_tab?(application_tab),
          )
        end
      end

      def application_choices_groups
        [@application_tabs.index('all'), @application_choices.map(&:application_choices_group)].flatten.uniq
      end

      def all_applications?
        params[:application_choices_group].blank? ||
          params[:application_choices_group] == 'all' ||
            @application_tabs.exclude?(params[:application_choices_group])
      end
    end
  end
end
