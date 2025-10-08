module ProviderInterface
  class ChangeChoicesToMainSite
    attr_reader :provider_ids, :current_year

    def initialize(provider_ids: [])
      @current_year = RecruitmentCycleTimetable.current_year
      @provider_ids = provider_ids
    end

    def self.call(provider_ids: [])
      new(provider_ids:).call
    end

    def call
      Rails.logger.debug 'Changing application choices to main site'

      providers = Provider.where(id: provider_ids, selectable_school: false)
      jobs_counter = 0

      if providers.present?
        providers.each do |provider|
          main_site_id = provider.sites.for_recruitment_cycle_years(current_year)
            .find_by(code: '-')&.id

          if main_site_id.nil?
            Rails.logger.debug { "Provider #{provider.id} does not have a main site" }
            next
          end

          choices = ApplicationChoice
            .joins(current_course_option: :site)
            .joins(:current_provider)
            .where(current_recruitment_cycle_year: current_year)
            .where.not(site: { id: main_site_id })
            .where('current_course_option_id = original_course_option_id')
            .where(current_provider: { id: provider.id, selectable_school: false })
            .select(:id)

          batch_size = 100
          choices.in_batches(of: batch_size) do |batch|
            Provider::ChangeChoicesToMainSiteWorker.perform_async(
              batch.ids,
              main_site_id,
            )
            jobs_counter += 1
          end
        end
        Rails.logger.debug { "Enqueued #{jobs_counter} jobs" }
      else
        Rails.logger.debug 'There are not providers to change choices for'
      end
    end
  end
end
