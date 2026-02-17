module Publications
  class StatusTotalsComponent < ApplicationComponent
    include ActiveModel::Model

    attr_accessor :title, :summary, :heading_one, :heading_two
    attr_writer :status_total_one, :status_total_two

    def status_total_one
      @status_total_one.to_i
    end

    def status_total_two
      @status_total_two.to_i
    end
  end
end
