class DeletedCandidate < ApplicationRecord
  def readonly?
    return true if !new_record?

    super
  end

  def delete
    raise 'DeletedCandidate is marked as readonly'
  end

  def self.delete(_id_or_array)
    raise 'DeletedCandidate is marked as readonly'
  end

  def self.delete_all(_conditions = nil)
    raise 'DeletedCandidate is marked as readonly'
  end

  def self.update_all(_updates, _conditions = nil, _options = {})
    raise 'DeletedCandidate is marked as readonly'
  end
end
