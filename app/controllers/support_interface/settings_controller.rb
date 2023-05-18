module SupportInterface
  class SettingsController < SupportInterfaceController
    def activate_feature_flag
      FeatureFlag.activate(params[:feature_name])

      SlackNotificationWorker.perform_async(
        ":flags: Feature ‘#{feature_name}‘ was activated",
        support_interface_feature_flags_url,
      )

      flash[:success] = "Feature ‘#{feature_name}’ activated"
      redirect_to support_interface_feature_flags_path
    end

    def deactivate_feature_flag
      FeatureFlag.deactivate(params[:feature_name])

      SlackNotificationWorker.perform_async(
        ":flags: Feature ‘#{feature_name}‘ was deactivated",
        support_interface_feature_flags_url,
      )

      flash[:success] = "Feature ‘#{feature_name}’ deactivated"
      redirect_to support_interface_feature_flags_path
    end

    def switch_cycle_schedule
      new_cycle = params[:support_interface_change_cycle_form][:cycle_schedule_name]
      SiteSetting.set(name: 'cycle_schedule', value: new_cycle)

      message = ":old_timey_parrot: Cycle schedule updated to #{new_cycle}"
      url = Rails.application.routes.url_helpers.support_interface_cycles_url
      SlackNotificationWorker.perform_async(message, url)

      flash[:success] = 'Cycle schedule updated'
      redirect_to support_interface_cycles_path
    end

    def mid_cycle_report; end

    def mid_cycle_report_upload
      publication_date = Date.new(
        *params.slice('publication_date(1i)', 'publication_date(2i)', 'publication_date(3i)').values.map(&:to_i),
      )

      provider_csv = CSV.parse(params.require(:provider_data), headers: true)
      Publications::ProviderMidCycleReport.ingest(provider_csv, publication_date)

      national_csv = CSV.parse(params.require(:national_data), headers: true)
      Publications::NationalMidCycleReport.ingest(national_csv, publication_date)

      flash[:success] = 'Mid cycle reports uploaded'
      redirect_to support_interface_mid_cycle_report_path
    end

  private

    def feature_name
      params[:feature_name].humanize
    end
  end
end
