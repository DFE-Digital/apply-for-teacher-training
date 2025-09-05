module CandidateInterface
  class ApplicationChoiceListComponent < ApplicationComponent
    attr_reader :application_form, :application_choices

    ALL_APPLICATIONS_TAB = 'all'.freeze
    ApplicationTab = Struct.new(:text, :link, :active?, keyword_init: true)

    def initialize(application_form:, application_choices:, current_tab_name: nil)
      @application_form = application_form
      @application_choices = application_choices
      @tabs = [ALL_APPLICATIONS_TAB, @application_choices.map(&:application_choices_group_name)].flatten.compact_blank.uniq
      @current_tab_name = current_tab_name
    end

    def render?
      @application_choices.present?
    end

    def tabs
      @tabs.map do |tab|
        ApplicationTab.new(
          text: I18n.t("candidate_interface.application_tabs.#{tab}"),
          link: candidate_interface_application_choices_path(current_tab_name: tab),
          active?: tab == current_tab_name,
        )
      end
    end

    def current_tab_application_choices
      return @application_choices if all_applications?

      @application_choices.select { |application_choice| application_choice.application_choices_group_name == current_tab_name }
    end

  private

    def all_applications?
      current_tab_name == ALL_APPLICATIONS_TAB
    end

    def current_tab_name
      return ALL_APPLICATIONS_TAB if @current_tab_name.blank? || @tabs.exclude?(@current_tab_name)

      @current_tab_name
    end
  end
end
