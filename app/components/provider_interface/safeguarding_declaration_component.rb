module ProviderInterface
  class SafeguardingDeclarationComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :current_provider_user

    def initialize(application_choice:, current_provider_user:)
      @application_choice = application_choice
      @current_provider_user = current_provider_user

      @auth = current_provider_user.authorisation
      @auth_result = @auth.can_view_safeguarding_information?(course: application_choice.course)
      @analysis = ProviderAuthorisationAnalysis.new(
        permission: :view_safeguarding_information,
        auth: @auth,
        application_choice: @application_choice,
      )
    end

    def rows
      rows = [{ key: I18n.t('provider_interface.safeguarding_declaration_component.declare_safeguarding_issues'), value: declare_safeguarding_issues }]

      if safeguarding_issues_declared?
        rows << { key: I18n.t('provider_interface.safeguarding_declaration_component.safeguarding_information'), value: safeguarding_information }
      end

      previous_training_rows(rows)
    end

  private

    def declare_safeguarding_issues
      if safeguarding_issues_declared?
        I18n.t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare')
      else
        I18n.t('provider_interface.safeguarding_declaration_component.no_safeguarding_issues_to_declare')
      end
    end

    def safeguarding_information
      if current_user_has_permission_to_view_safeguarding_information?
        application_choice.application_form.safeguarding_issues
      else
        t('provider_interface.safeguarding_declaration_component.cannot_see_safeguarding_information')
      end
    end

    def previous_training_rows(rows)
      return rows if previous_training_record.blank?

      rows << { key: t('provider_interface.safeguarding_declaration_component.have_you_started'), value: previous_training_record.started.capitalize }

      if previous_training_record.started_yes?
        rows.tap do |collection|
          collection << { key: t('provider_interface.safeguarding_declaration_component.name_of_training_provider'), value: previous_training_record.provider_name }
          collection << { key: t('provider_interface.safeguarding_declaration_component.training_dates'), value: previous_training_record.formatted_dates }
          collection << { key: t('provider_interface.safeguarding_declaration_component.details'), value: previous_training_record.details }
        end
      end

      rows
    end

    def current_user_has_permission_to_view_safeguarding_information?
      @auth_result
    end

    def safeguarding_issues_declared?
      application_form.has_safeguarding_issues_to_declare?
    end

    def application_form
      @application_form ||= application_choice.application_form
    end

    def previous_training_record
      @previous_training_record ||= @application_form.published_previous_teacher_training
    end
  end
end
