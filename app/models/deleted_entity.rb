class DeletedEntity < ApplicationRecord
  def readonly?
    return true if !new_record?

    super
  end

  def delete
    raise 'DeletedEntity is marked as readonly'
  end

  def self.delete(_id_or_array)
    raise 'DeletedEntity is marked as readonly'
  end

  def self.delete_all(_conditions = nil)
    raise 'DeletedEntity is marked as readonly'
  end

  def self.update_all(_updates, _conditions = nil, _options = {})
    raise 'DeletedEntity is marked as readonly'
  end
end
