module Chased
  extend ActiveSupport::Concern

  included do
    has_many :chasers_sent, as: :chased, dependent: :destroy
  end
end
