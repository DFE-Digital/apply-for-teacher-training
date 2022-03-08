module CandidateInterface
  module Degrees
    class DegreeController < BaseController
      before_action :redirect_to_old_degree_flow_unless_feature_flag_is_active

      def new
        @wizard = DegreeWizard.new(degree_store)
      end

      alias new_country new
      alias new_level new
      alias new_subject new
      alias new_type new
      alias new_university new
      alias new_completed new
      alias new_grade new
      alias new_start_year new
      alias new_award_year new
      alias new_enic new

      def update(current_step)
        @wizard = DegreeWizard.new(degree_store, degree_params.merge({ current_step: current_step }))

        if @wizard.valid_for_current_step?
          @wizard.save_state!
          redirect_to [:candidate_interface, :degrees, @wizard.next_step]
        else
          render :"new_#{current_step}"
        end
      end

      def update_country
        update(:country)
      end

      def update_level
        update(:level)
      end

      def update_subject
        update(:subject)
      end

      def update_type
        update(:type)
      end

      def update_university
        update(:university)
      end

      def update_completed
        update(:completed)
      end

      def update_grade
        update(:grade)
      end

      def update_start_year
        update(:start_year)
      end

      def update_award_year
        @wizard = DegreeWizard.new(degree_store, degree_params.merge({ current_step: :award_year }))

        if @wizard.valid_for_current_step?
          @wizard.save_state!
          next_step!
        else
          render :new_award_year
        end
      end

      def update_enic
        @wizard = DegreeWizard.new(degree_store, degree_params.merge({ current_step: :enic }))

        if @wizard.valid_for_current_step?
          @wizard.save_state!
          next_step!
        else
          render :new_enic
        end
      end

    private

      def next_step!
        if @wizard.next_step == :review
          current_application.application_qualifications.degree.create!(@wizard.attributes_for_persistence)
        end
        redirect_to [:candidate_interface, :degrees, @wizard.next_step]
      end

      def degree_store
        key = "degree_wizard_store_#{current_user.id}_#{current_application.id}"
        WizardStateStores::RedisStore.new(key: key)
      end

      def degree_params
        params.require(:candidate_interface_degree_wizard).permit(:uk_or_non_uk, :country, :subject, :level, :equivalent_level, :type, :international_type,
                                                                  :other_type, :university, :completed, :grade, :have_grade, :other_grade, :start_year, :award_year, :have_enic_reference, :enic_reference,
                                                                  :comparable_uk_degree)
      end

      def redirect_to_old_degree_flow_unless_feature_flag_is_active
        redirect_to candidate_interface_new_degree_path unless FeatureFlag.active?(:new_degree_flow)
      end
    end
  end
end
