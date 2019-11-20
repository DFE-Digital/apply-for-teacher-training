class Reference < ApplicationRecord
  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :email_address, presence: true,
                            email_address: true,
                            length: { maximum: 100 },
                            uniqueness: { scope: :application_form_id }
  validates :relationship, presence: true, length: { minimum: 2, maximum: 500 }
  validates_presence_of :application_form_id

  belongs_to :application_form

  audited associated_with: :application_form

  def complete?
    feedback.present?
  end

  def ordinal
    self.application_form.references.find_index(self).to_i + 1
  end
end
