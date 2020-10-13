module ProviderInterface
  class ApplicationsExportForm
    include ActiveModel::Model

    Choice = Struct.new(:id, :name)

    validate :providers_selected
    validate :recruitment_cycle_years_selected
    validate :statuses_selected, if: -> { filter_by_status == 'true' }

    attr_accessor :filter_by_status, :include_diversity_information, :provider_ids,
                  :recruitment_cycle_years, :statuses

    def status_options
      HesaDataExport::STATUSES.map do |status_key, _statuses|
        Choice.new(status_key, status_key.humanize)
      end
    end

    def recruitment_cycle_options
      [
        Choice.new(2019, 'Previous cycle (2019 to 2020)'),
        Choice.new(2020, 'Current cycle (2020 to 2021)'),
      ]
    end

    def providers_selected
      errors.add(:provider_ids, 'Select at least one organisation') if provider_ids.reject(&:blank?).empty?
    end

    def recruitment_cycle_years_selected
      errors.add(:recruitment_cycle_years, 'Select at least one cycle') if recruitment_cycle_years.reject(&:blank?).empty?
    end

    def statuses_selected
      errors.add(:statuses, 'Select at least one status') if statuses.reject(&:blank?).empty?
    end
  end
end
