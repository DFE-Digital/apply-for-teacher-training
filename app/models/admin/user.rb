class Admin::User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise  :database_authenticatable,
          :recoverable,
          :rememberable,
          :validatable,
          :trackable,
          :lockable
end
