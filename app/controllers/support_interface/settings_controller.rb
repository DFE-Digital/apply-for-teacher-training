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

    def notify_template
      Subject.last.dup.save!
      @form = SupportInterface::NotifyTemplateForm.new
    end

    def send_notify_template
      @form = SupportInterface::NotifyTemplateForm.new(
        notify_template_params.merge(support_user: current_user),
      )

      if @form.valid?
        request = @form.create_request!
        request.send_emails

        flash[:success] = 'Email sent'
        redirect_to support_interface_notify_template_path
      elsif @form.invalid_email_address_rows.present?
        render :notify_template_errors
      else
        render :notify_template
      end
    end

    def feature_flags
      feature_names = FeatureFlag::FEATURES.map(&:first)
      @obsolete_features = Feature
                             .where.not(name: feature_names)
                             .order(:name)
                             .map(&:name)
    end

  private

    def feature_name
      params[:feature_name].humanize
    end

    def notify_template_params
      params.expect(support_interface_notify_template_form: %i[template_id attachment distribution_list])
    end
  end
end
