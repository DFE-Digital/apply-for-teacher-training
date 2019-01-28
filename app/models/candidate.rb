class Candidate < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :rememberable,
          :validatable,
          :trackable,
          :lockable

  enum gender: { male: 0, female: 1, not_sure: 2, prefer_not_to_disclose: 3 }

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :title, presence: true
  validates :first_name, presence: true
  validates :surname, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true

  def full_name
    [first_name, surname].join(' ')
  end
end
