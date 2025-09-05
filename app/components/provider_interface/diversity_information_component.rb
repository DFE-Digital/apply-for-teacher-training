module ProviderInterface
  class DiversityInformationComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_choice, :current_provider_user

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user
    end

    def rows
      return [] unless application_choice.application_form.equality_and_diversity_answers_provided?

      [
        { key: I18n.t('equality_and_diversity.sex.title'), value: row_value(equality_and_diversity['sex'].capitalize) },
        { key: I18n.t('equality_and_diversity.disabilities.title'), value: row_value(disability_value.html_safe) },
        { key: I18n.t('equality_and_diversity.ethnic_group.title'), value: row_value(equality_and_diversity['ethnic_group']) },
      ].tap do |array|
        if equality_and_diversity['ethnic_background'].present? && application_in_correct_state?
          array << {
            key: I18n.t('equality_and_diversity.ethnic_background.title', group: equality_and_diversity['ethnic_group']),
            value: row_value(equality_and_diversity['ethnic_background']),
          }
        end
      end
    end

  private

    def row_value(value)
      return 'You cannot view this because you do not have permission to view sex, disability and ethnicity information.' unless current_user_has_permission_to_view_diversity_information?
      return 'You will be able to view this if the candidate accepts an offer for this application.' unless application_in_correct_state?

      value
    end

    def offer_context
      application_choice.offer? ? 'your' : 'an'
    end

    def disability_value
      disabilities = Array(equality_and_diversity['disabilities'])
      disability_list_items = disabilities.map do |disability|
        "<li>#{disability} </li>"
      end

      "<ul class=\"govuk-list\">#{disability_list_items.join}</ul>"
    end

    def application_in_correct_state?
      ApplicationStateChange::POST_OFFERED_STATES.include?(application_choice.status.to_sym)
    end

    def current_user_has_permission_to_view_diversity_information?
      current_provider_user.authorisation
        .can_view_diversity_information?(course: application_choice.current_course)
    end

    def equality_and_diversity
      @equality_and_diversity ||= application_choice.application_form.equality_and_diversity
    end
  end
end
