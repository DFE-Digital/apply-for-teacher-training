module CandidateInterface
  class DecoupledReferencesController < CandidateInterfaceController
    before_action :redirect_to_application_form_if_flag_is_not_active
    before_action :set_reference, only: %i[name update_name]

    def start; end

    def type
      @reference_type_form = Reference::RefereeTypeForm.new
    end

    def update_type
      @reference_type_form = Reference::RefereeTypeForm.new(referee_type: referee_type_param)
      return render :type unless @reference_type_form.valid?

      @reference_type_form.save(current_application)

      redirect_to candidate_interface_decoupled_references_name_path(current_application.application_references.last.id)
    end

    def name
      @reference_name_form = Reference::RefereeNameForm.new
    end

    def update_name
      @reference_name_form = Reference::RefereeNameForm.new(name: referee_name_param)
      return render :name unless @reference_name_form.valid?

      @reference_name_form.save(@reference)

      redirect_to candidate_interface_decoupled_references_email_path(@reference.id)
    end

  private

    def redirect_to_application_form_if_flag_is_not_active
      redirect_to candidate_interface_application_form_path unless FeatureFlag.active?('decoupled_references')
    end

    def set_reference
      @reference = current_candidate.current_application
                                    .application_references
                                    .includes(:application_form)
                                    .find_by(id: params[:id])
    end

    def referee_type_param
      params.dig(:candidate_interface_reference_referee_type_form, :referee_type)
    end

    def referee_name_param
      params.dig(:candidate_interface_reference_referee_name_form, :name)
    end
  end
end
