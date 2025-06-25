module ProviderInterface
  module Offer
    class SkeRequirementsController < SkeController
      def create
        super do |wizard|
          wizard.ske_conditions = build_ske_conditions

          if no_options_selected?
            wizard.errors.add(:base, :blank)
          elsif no_and_languages_selected?
            wizard.errors.add(:base, :no_and_languages_selected)
          end
        end
      end

      def update
        super do |wizard|
          wizard.ske_conditions = build_ske_conditions

          if no_options_selected?
            wizard.errors.add(:base, :blank)
          elsif no_and_languages_selected?
            wizard.errors.add(:base, :no_and_languages_selected)
          end
        end
      end

    private

      def ske_flow_params
        {}
      end

      def ske_flow_step
        'ske_requirements'
      end

      def build_ske_conditions
        if ske_required?
          if language_ske?
            required_languages.map do |subject|
              SkeCondition.new(
                graduation_cutoff_date:,
                subject:,
                subject_type: 'language',
              )
            end
          else
            [
              SkeCondition.new(
                graduation_cutoff_date:,
                subject: @wizard.subject_name,
                subject_type: 'standard',
              ),
            ]
          end
        else
          []
        end
      end

      def ske_required?
        offer_wizard_params[:ske_required] == 'true' || required_languages.any?
      end

      def required_languages
        selected_options - ['no']
      end

      def selected_options
        Array(offer_wizard_params[:ske_languages]).compact_blank
      end

      def no_options_selected?
        if language_ske?
          selected_options.none?
        else
          offer_wizard_params[:ske_required].blank?
        end
      end

      def no_and_languages_selected?
        selected_options.many? && selected_options.include?('no')
      end

      def graduation_cutoff_date
        (@application_choice.current_course.start_date - 5.years).iso8601
      end
    end
  end
end
