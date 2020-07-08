module ApplyMailersController
  def preview
    ActiveRecord::Base.transaction do
      super
      raise ActiveRecord::Rollback
    end
  end
end
