module Publications
  class StatusTotalsComponent < ViewComponent::Base
    include ActiveModel::Model
    attr_accessor :title, :summary, :heading1, :value1, :heading2, :value2
  end
end
