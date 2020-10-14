module SupportInterface
  class SettingsController < SupportInterfaceController
    def activate_feature_flag
      FeatureFlag.activate(params[:feature_name])
      flash[:success] = "Feature ‘#{params[:feature_name].humanize}’ activated"
      redirect_to support_interface_feature_flags_path
    end

    def deactivate_feature_flag
      FeatureFlag.deactivate(params[:feature_name])
      flash[:success] = "Feature ‘#{params[:feature_name].humanize}’ deactivated"
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
  end
end
