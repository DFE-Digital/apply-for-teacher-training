module Publications
  class StatusTotalsComponent < ViewComponent::Base
    include ActiveModel::Model
    attr_accessor :title, :summary, :heading_one, :status_total_one, :heading_two, :status_total_two
  end
end
