module ProviderInterface
  class ApplicationDataExportForm
    include ActiveModel::Model

    TRANSLATION_KEY_PREFIX = 'activemodel.errors.models.provider_interface/application_data_export_form.attributes'.freeze

    attr_accessor :current_provider_user, :provider_ids, :recruitment_cycle_years, :application_status_choice, :statuses

    validate :at_least_one_recruitment_cycle_year_is_selected
    validates :application_status_choice, presence: true
    validate :at_least_one_status_is_selected, if: :custom_status_selected?
    validate :at_least_one_provider_is_selected, if: :actor_has_more_than_one_provider?

    def selected_years
      recruitment_cycle_years.compact_blank
    end

    def years_to_export
      choices = GetApplicationChoicesForProviders.call(
        providers: providers_that_actor_belongs_to,
        recruitment_cycle_year: RecruitmentCycleTimetable.pluck(:recruitment_cycle_year),
      )
      choices.map(&:current_recruitment_cycle_year).uniq.sort.reverse
    end

    def providers_that_actor_belongs_to
      @_providers_that_actor_belongs_to ||= current_provider_user.providers
    end

    def selected_providers
      actor_has_more_than_one_provider? ? providers_that_actor_belongs_to.where(id: provider_ids) : providers_that_actor_belongs_to
    end

    def custom_status_selected?
      application_status_choice == 'custom'
    end

    def selected_statuses
      statuses.push('inactive') if statuses.include?('awaiting_provider_decision')

      custom_status_selected? ? statuses : ApplicationStateChange.states_visible_to_provider
    end

    def actor_has_more_than_one_provider?
      providers_that_actor_belongs_to.count > 1
    end

  private

    def at_least_one_recruitment_cycle_year_is_selected
      if recruitment_cycle_years.all?(&:blank?)
        errors.add(:recruitment_cycle_years, I18n.t("#{TRANSLATION_KEY_PREFIX}.recruitment_cycle_years.blank"))
      end
    end

    def at_least_one_status_is_selected
      if statuses.all?(&:blank?)
        errors.add(:statuses, I18n.t("#{TRANSLATION_KEY_PREFIX}.statuses.blank"))
      end
    end

    def at_least_one_provider_is_selected
      if selected_providers.none?
        errors.add(:provider_ids, I18n.t("#{TRANSLATION_KEY_PREFIX}.provider_ids.blank"))
      end
    end
  end
end
