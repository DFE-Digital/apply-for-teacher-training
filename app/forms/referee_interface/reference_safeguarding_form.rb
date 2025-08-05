module RefereeInterface
  class ReferenceSafeguardingForm
    include ActiveModel::Model

    attr_accessor :any_safeguarding_concerns, :safeguarding_concerns, :candidate

    validate :presence_of_any_safeguarding_concerns
    validate :presence_of_safeguarding_concerns
    validates :safeguarding_concerns, word_count: { maximum: 150 }

    def self.build_from_reference(reference:)
      any_safeguarding_concerns = reference.safeguarding_concerns.blank? ? 'no' : 'yes' unless reference.safeguarding_concerns.nil?

      new(any_safeguarding_concerns:, safeguarding_concerns: reference.safeguarding_concerns)
    end

    def save(application_reference)
      return false unless valid?

      ApplicationForm.with_unsafe_application_choice_touches do
        application_reference.update!(
          safeguarding_concerns: any_safeguarding_concerns == 'yes' ? safeguarding_concerns : '',
          safeguarding_concerns_status: any_safeguarding_concerns == 'yes' ? :has_safeguarding_concerns_to_declare : :no_safeguarding_concerns_to_declare,
        )
      end
    end

  private

    def presence_of_any_safeguarding_concerns
      return if any_safeguarding_concerns.present?

      any_safeguarding_concerns_blank =
        I18n.t(
          'activemodel.errors.models.referee_interface/reference_safeguarding_form.attributes.any_safeguarding_concerns.blank',
          candidate:,
        )
      errors.add(:any_safeguarding_concerns, any_safeguarding_concerns_blank)
    end

    def presence_of_safeguarding_concerns
      return unless any_safeguarding_concerns == 'yes'
      return if safeguarding_concerns.present?

      safeguarding_concerns_blank =
        I18n.t(
          'activemodel.errors.models.referee_interface/reference_safeguarding_form.attributes.safeguarding_concerns.blank',
          candidate:,
        )
      errors.add(:safeguarding_concerns, safeguarding_concerns_blank)
    end
  end
end
