module SupportInterface
  module ApplicationForms
    class EditDegreeForm
      include ActiveModel::Model

      attr_reader :degree
      attr_accessor :award_year, :start_year, :audit_comment

      validates :start_year, presence: true
      validates :award_year, presence: true
      validates :audit_comment, presence: true

      delegate :application_form, :subject, to: :degree

      def initialize(degree)
        @degree = degree

        super(
          award_year: @degree.award_year,
          start_year: @degree.start_year,
        )
      end

      def save!
        @degree.update!(
          start_year: start_year,
          award_year: award_year,
          audit_comment: audit_comment,
        )
      end
    end
  end
end
