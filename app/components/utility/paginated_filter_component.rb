class PaginatedFilterComponent < BaseComponent
  attr_reader :filter, :collection

  def initialize(filter:, collection:)
    @filter = filter
    @collection = collection
  end
end
