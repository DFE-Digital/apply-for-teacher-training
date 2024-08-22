module CandidateInterface
  module Degrees
    class DegreeController < BaseController
      def new
        degree_attrs = { application_form_id: current_application.id }
        degree_attrs[:id] = params[:id] if params.key?(:id)
        @wizard = DegreeWizard.new(degree_store, degree_attrs)
        @wizard.referer = request.referer
        @wizard.save_state!
      end

      def edit
        @wizard = DegreeWizard.from_application_qualification(degree_store, current_application.application_qualifications.find(params[:id]))
        @wizard.save_state!
        redirect_to [:candidate_interface, :degree, params[:step].to_sym]
      end

      def new_country
        degree_attrs = { application_form_id: current_application.id }
        degree_attrs[:id] = params[:id] if params.key?(:id)
        @wizard = DegreeWizard.new(degree_store, degree_attrs)

        if params[:context] == 'new_degree'
          @wizard.uk_or_non_uk = nil
          @wizard.country = nil
          @wizard.clear_state!
        else
          @wizard.referer = request.referer
          @wizard.save_state!
        end
      end

      alias new_degree_level new
      alias new_subject new
      alias new_type new
      alias new_university new
      alias new_completed new
      alias new_grade new
      alias new_start_year new
      alias new_award_year new
      alias new_enic new
      alias new_enic_reference new

      def update(current_step)
        set_country_for_uk
        @wizard = DegreeWizard.new(degree_store, degree_params.merge({ current_step: }))

        if @wizard.valid_for_current_step?
          @wizard.save_state!
          next_step!
        else
          render :"new_#{current_step}"
        end
      end

      %i[country degree_level subject type university completed grade start_year enic enic_reference].each do |step|
        define_method("update_#{step}") { update(step) }
      end

      def update_award_year
        @wizard = DegreeWizard.new(degree_store, degree_params.merge({ current_step: :award_year, recruitment_cycle_year: current_application.recruitment_cycle_year }))

        if @wizard.valid_for_current_step?
          @wizard.save_state!
          next_step!
        else
          render :new_award_year
        end
      end

    private

      def set_country_for_uk
        if params.dig(:candidate_interface_degree_wizard, :uk_or_non_uk) == 'uk'
          params[:candidate_interface_degree_wizard][:country] = 'GB'
        end
      end

      def next_step!
        if @wizard.next_step == :review
          @wizard.persist!
        end

        redirect_to [:candidate_interface, :degree, @wizard.next_step]
      end

      def degree_store
        key = "degree_wizard_store_#{current_user.id}_#{current_application.id}"
        WizardStateStores::RedisStore.new(key:)
      end

      def degree_params
        if params[:candidate_interface_degree_wizard].present?
          strip_whitespace params.require(:candidate_interface_degree_wizard).permit(
            :uk_or_non_uk, :country, :subject, :subject_raw, :degree_level, :equivalent_level,
            :type, :international_type, :other_type, :other_type_raw, :university, :university_raw,
            :completed, :grade, :other_grade, :other_grade_raw, :start_year, :award_year,
            :enic_reference, :comparable_uk_degree, :enic_reason
          )
        else
          {}
        end
      end
    end
  end
end
