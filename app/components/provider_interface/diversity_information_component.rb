module ProviderInterface
  class DiversityInformationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :current_provider_user

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user
    end

    def rows
      rows = [{ key: 'Do you want to answer a few questions about your sex, disability and ethnicity?', value: diversity_information_declared? ? 'Yes' : 'No' }]

      if diversity_information_declared?
        rows << { key: I18n.t('equality_and_diversity.sex.title'), value: row_value(equality_and_diversity['sex'].capitalize) }
        rows << { key: I18n.t('equality_and_diversity.disability_status.title'), value: row_value(disability_status) }
        rows << { key: I18n.t('equality_and_diversity.disabilities.title'), value: row_value(disability_value.html_safe) } if disability_status == 'Yes'
        rows << { key: I18n.t('equality_and_diversity.ethnic_group.title'), value: row_value(equality_and_diversity['ethnic_group']) }
        if equality_and_diversity['ethnic_background'].present? && application_in_correct_state?
          rows << {
            key: I18n.t('equality_and_diversity.ethnic_background.title', group: equality_and_diversity['ethnic_group']),
            value: row_value(equality_and_diversity['ethnic_background']),
          }
        end
      end

      rows
    end

    def diversity_information_declared?
      application_choice.application_form.equality_and_diversity_answers_provided?
    end

  private

    def row_value(value)
      return 'You cannot view this because you do not have permission to view sex, disability and ethnicity information.' unless current_user_has_permission_to_view_diversity_information?
      return "You'll be able to view this if the candidate accepts an offer for this application." unless application_in_correct_state?

      value
    end

    def offer_context
      application_choice.offer? ? 'your' : 'an'
    end

    def disability_status
      return 'Prefer not to say' if equality_and_diversity['disabilities'].include?('Prefer not to say')

      return 'Yes' if equality_and_diversity['disabilities'].any?

      'No'
    end

    def disability_value
      disabilities = equality_and_diversity['disabilities'].map do |disability|
        "<li>#{disability} </li>"
      end

      "<p class=\"govuk-body govuk-margin-top-0>\">The candidate disclosed the following #{'disability'.pluralize(disabilities.count)}:</p>
      <ul class=\"govuk-list\">#{disabilities.join}</ul>"
    end

    def application_in_correct_state?
      ApplicationStateChange::POST_OFFERED_STATES.include?(application_choice.status.to_sym)
    end

    def current_user_has_permission_to_view_diversity_information?
      current_provider_user.authorisation
        .can_view_diversity_information?(course: application_choice.course)
    end

    def equality_and_diversity
      @equality_and_diversity ||= application_choice.application_form.equality_and_diversity
    end
  end
end
