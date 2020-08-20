class UCASMatch < ApplicationRecord
  audited

  belongs_to :candidate

  enum matching_state: {
    matching_data_updated: 'matching_data_updated',
    new_match: 'new_match',
    processed: 'processed',
  }
end
