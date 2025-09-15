module SupportInterface
  class SettingsController < SupportInterfaceController
    def activate_feature_flag
      FeatureFlag.activate(params[:feature_name])

      flash[:success] = "Feature ‘#{feature_name}’ activated"
      redirect_to support_interface_feature_flags_path
    end

    def deactivate_feature_flag
      FeatureFlag.deactivate(params[:feature_name])

      flash[:success] = "Feature ‘#{feature_name}’ deactivated"
      redirect_to support_interface_feature_flags_path
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

      flash[:success] = 'Email sent'
      redirect_to support_interface_notify_template_path
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
