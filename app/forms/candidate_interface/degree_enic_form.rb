module CandidateInterface
  class DegreeEnicForm
    include ActiveModel::Model

    attr_accessor :degree, :have_enic_reference, :enic_reference, :comparable_uk_degree

    delegate :international?, to: :degree, allow_nil: true

    alias have_enic_reference? have_enic_reference

    validates :have_enic_reference, presence: true
    validates :enic_reference, presence: true, if: -> { have_enic_reference == 'yes' }
    validates :comparable_uk_degree, presence: true, if: -> { have_enic_reference == 'yes' }

    def save
      return false unless valid?

      degree.update!(
        enic_reference: have_enic_reference? == 'yes' ? enic_reference : nil,
        comparable_uk_degree: have_enic_reference? == 'yes' ? comparable_uk_degree : nil,
      )
    end

    def assign_form_values
      self.have_enic_reference = set_have_enic_references
      self.enic_reference = degree.enic_reference
      self.comparable_uk_degree = degree.comparable_uk_degree
      self
    end

  private

    def set_have_enic_references
      if degree.enic_reference.present?
        'yes'
      elsif degree.comparable_uk_degree.blank? && degree.award_year.blank?
        nil
      else
        'no'
      end
    end
  end
end
