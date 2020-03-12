class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    if filters[:search]
       search_array = prepare_search_array(filters[:search][:candidates_name])
       application_choices.where("first_name ILIKE ANY (array[?])", search_array)
         .or(application_choices.where("last_name ILIKE ANY (array[?])", search_array))
    elsif filters[:status] && filters[:provider]
      application_choices.where(status: filters[:status].keys, 'courses.provider_id' => filters[:provider].keys)
    elsif filters[:status]
      application_choices.where(status: filters[:status].keys)
    else
      application_choices.where('courses.provider_id' => filters[:provider].keys)
    end
  end

 def self.prepare_search_array(search_terms)
   search_terms.downcase.gsub(/\W /, '').split
 end
end


