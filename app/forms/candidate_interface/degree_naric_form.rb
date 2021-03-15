module CandidateInterface
  class DegreeNaricForm
    include ActiveModel::Model

    attr_accessor :degree, :have_naric_reference, :naric_reference, :comparable_uk_degree

    delegate :international?, to: :degree, allow_nil: true

    alias_method :have_naric_reference?, :have_naric_reference

    validates :have_naric_reference, presence: true
    validates :naric_reference, presence: true, if: -> { have_naric_reference == 'yes' }
    validates :comparable_uk_degree, presence: true, if: -> { have_naric_reference == 'yes' }

    def save
      return false unless valid?

      degree.update!(
        naric_reference: have_naric_reference? == 'yes' ? naric_reference : nil,
        enic_reference: have_naric_reference? == 'yes' ? naric_reference : nil,
        comparable_uk_degree: have_naric_reference? == 'yes' ? comparable_uk_degree : nil,
      )
    end

    def assign_form_values
      self.have_naric_reference = (degree.naric_reference.present? ? 'yes' : 'no')
      self.naric_reference = degree.naric_reference
      self.comparable_uk_degree = degree.comparable_uk_degree
      self
    end
  end
end
