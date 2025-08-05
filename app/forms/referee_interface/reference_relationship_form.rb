module RefereeInterface
  class ReferenceRelationshipForm
    include ActiveModel::Model

    attr_accessor :relationship_confirmation, :relationship_correction, :candidate

    validates :relationship_confirmation, presence: true
    validate :presence_of_relationship_correction
    validates :relationship_correction, word_count: { maximum: 50 }

    def self.build_from_reference(reference:)
      relationship_confirmation = reference.relationship_correction.blank? ? 'yes' : 'no' unless reference.relationship_correction.nil?
      new(relationship_confirmation:, relationship_correction: reference.relationship_correction, candidate: reference.application_form.full_name)
    end

    def save(application_reference)
      return false unless valid?

      correction = relationship_confirmation == 'yes' ? '' : relationship_correction

      ApplicationForm.with_unsafe_application_choice_touches do
        application_reference.update!(relationship_correction: correction)
      end
    end

    def presence_of_relationship_correction
      return if relationship_confirmation.nil?
      return if relationship_confirmation == 'yes' || relationship_correction.present?

      relationship_correction_blank = I18n.t('activemodel.errors.models.referee_interface/reference_relationship_form.attributes.relationship_correction.blank', candidate:)
      errors.add(:relationship_correction, relationship_correction_blank)
    end
  end
end
