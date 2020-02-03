class ChaserSent < ApplicationRecord
  belongs_to :chased, polymorphic: true

  enum chaser_type: {
    referee_mailer_reference_request_chaser_email: 'referee_mailer_reference_request_chaser_email',
  }
end
