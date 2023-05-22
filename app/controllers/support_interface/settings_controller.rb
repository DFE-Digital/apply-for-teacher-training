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

    def notify_template; end

    def send_notify_template
      notify_template_id = params.require(:template_id)
      distribution_list = params.require(:distribution_list).read
      pdf_handle = StringIO.new(params.require(:attachment).read)
      client = Notifications::Client.new(ENV['GOVUK_NOTIFY_API_KEY'])

      actually_email_providers!(
        client,
        csv_to_hashes(distribution_list),
        notify_template_id,
        pdf_handle,
      )
    end

  private

    def actually_email_providers!(client, user_hashes, template, pdf_handle)
      user_hashes.each do |h|
        send_email(client, template, h['Email address'], pdf_handle)
      end
    end

    def csv_to_hashes(csv)
      CSV.parse(csv, headers: true).map do |row|
        h = row.to_h
        h.keys.zip(h.values.map(&:strip)).to_h
      end
    end

    def send_email(client, template, address, pdf_handle)
      pdf_handle.rewind
      client.send_email(
        email_address: address,
        template_id: template,
        personalisation: {
          pdf_link: Notifications.prepare_upload(pdf_handle),
        },
      )
    end

    def feature_name
      params[:feature_name].humanize
    end
  end
end
