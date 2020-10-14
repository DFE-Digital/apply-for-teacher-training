class DataExport < ApplicationRecord
  belongs_to :initiator, polymorphic: true
  audited except: [:data]

  def filename
    "#{name.parameterize}-#{created_at}.csv"
  end

  def generation_time
    (completed_at - created_at).seconds.ceil
  end
end
