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

  enum gender: { female: 0, male: 1, other: 2, prefer_not_to_say: 3 }

  validates :title, presence: true
  validates :first_name, presence: true
  validates :surname, presence: true
  validates :date_of_birth, presence: true
  validates :gender, presence: true

  def full_name
    [first_name, surname].join(' ')
  end

  def to_s
    full_name
  end
end
