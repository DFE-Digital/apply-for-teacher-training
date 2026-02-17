module ProviderInterface
  class SkeReasonComponent < ApplicationComponent
    attr_reader :application_choice, :offer_wizard, :form, :key

    SkeReason = Struct.new(:id, :name, keyword_init: true)

    def initialize(application_choice:, offer_wizard:, form:, radio_options: {}, key: :reason)
      @key = key
      @offer_wizard = offer_wizard
      @application_choice = application_choice
      @form = form
      @radio_options = radio_options
    end

    def options(ske_condition)
      [
        SkeReason.new(id: SkeCondition::DIFFERENT_DEGREE_REASON, name: first_option_label(ske_condition)),
        SkeReason.new(id: SkeCondition::OUTDATED_DEGREE_REASON, name: second_option_label(ske_condition)),
      ]
    end

    def radio_options(ske_condition)
      if @offer_wizard.language_course? && @offer_wizard.ske_conditions.many?
        {
          legend: {
            text: t(
              'provider_interface.offer.ske_reasons.form.title_language',
              language: ske_condition.subject,
            ),
          },
        }
      else
        @radio_options
      end
    end

  private

    def first_option_label(ske_condition)
      I18n.t(
        'provider_interface.offer.ske_reasons.different_degree',
        degree_subject: ske_condition.subject.capitalize,
      )
    end

    def second_option_label(ske_condition)
      I18n.t(
        'provider_interface.offer.ske_reasons.outdated_degree',
        degree_subject: ske_condition.subject.capitalize,
        graduation_cutoff_date: SkeConditionPresenter.new(ske_condition).cutoff_date,
      )
    end
  end
end
