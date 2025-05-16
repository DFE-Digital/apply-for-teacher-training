module SupportInterface
  module ApplicationForms
    class EditDegreeForm
      include ActiveModel::Model

      attr_reader :degree
      attr_accessor :award_year,
                    :start_year,
                    :has_enic_reference,
                    :enic_reference,
                    :comparable_uk_degree,
                    :enic_reason,
                    :audit_comment

      validates :start_year, presence: true
      validates :award_year, presence: true
      validates :has_enic_reference, presence: true, if: -> { international? }
      validates :enic_reference, :comparable_uk_degree, presence: true, if: -> { has_enic_reference == 'yes' }
      validate :enic_reason_validation
      validates :audit_comment, presence: true

      validates_with SafeChoiceUpdateValidator

      delegate :application_form, :subject, :international, to: :degree
      alias international? international

      def initialize(degree)
        @degree = degree

        super(
          award_year: @degree.award_year,
          start_year: @degree.start_year,
          has_enic_reference: @degree.enic_reference.present? ? 'yes' : 'no',
          enic_reference: @degree.enic_reference,
          comparable_uk_degree: @degree.comparable_uk_degree,
          enic_reason: @degree.enic_reason,
        )
      end

      def enic_reason_options
        ApplicationQualification.enic_reasons.values.filter { |reason| reason != 'obtained' }
      end

      def comparable_degree_options
        ApplicationQualification.comparable_uk_degrees.values
      end

      def enic_reason_validation
        return unless international?
        return if has_enic_reference == 'yes'
        return if enic_reason.in? enic_reason_options

        errors.add(:enic_reason, :blank)
      end

      def save!
        attributes = {
          start_year:,
          award_year:,
          audit_comment:,
        }

        if has_enic_reference == 'yes'
          attributes.merge!(
            enic_reference:,
            comparable_uk_degree:,
            enic_reason: 'obtained',
          )
        else
          attributes.merge!(
            enic_reference: nil,
            comparable_uk_degree: nil,
            enic_reason:,
          )
        end
        @degree.update!(**attributes)
      end
    end
  end
end
