module ProviderInterface
  class SkeReasonComponent < ViewComponent::Base
    attr_reader :application_choice, :offer_wizard, :form, :key

    SkeReason = Struct.new(:name, keyword_init: true)

    def initialize(application_choice:, offer_wizard:, form:, radio_options: {}, key: :reason)
      @key = key
      @offer_wizard = offer_wizard
      @application_choice = application_choice
      @form = form
      @radio_options = radio_options
    end

    def options(ske_condition)
      subject = ske_condition.language.presence || @application_choice.current_course.subjects.first&.name

      [
        SkeReason.new(name: first_option_label(subject)),
        SkeReason.new(name: second_option_label(subject)),
      ]
    end

    def radio_options(ske_condition)
      if @offer_wizard.language_course? && @offer_wizard.ske_languages.many?
        {
          legend: {
            text: t(
              'provider_interface.offer.ske_reasons.new.title_language',
              language: ske_condition.language,
            ),
          },
        }
      else
        @radio_options
      end
    end

  private

    def first_option_label(subject)
      I18n.t(
        'provider_interface.offer.ske_reasons.new.different_degree',
        degree_subject: subject.capitalize,
      )
    end

    def second_option_label(subject)
      graduation_date = @application_choice.current_course.start_date - 5.years

      I18n.t(
        'provider_interface.offer.ske_reasons.new.outdated_degree',
        degree_subject: subject.capitalize,
        graduation_date: graduation_date.to_fs(:month_and_year),
      )
    end
  end
end
