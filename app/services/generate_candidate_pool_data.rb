class GenerateCandidatePoolData
  def self.call
    new.call
  end

  def call
    return if HostingEnvironment.production?

    CandidatePoolProviderOptIn.insert_all(
      Provider.ids.map { |provider_id| { provider_id: } },
    )

    application_forms = Pool::Candidates.new.curated_application_forms

    locations = [
      { name: 'Manchester UK', coordinates: [53.4807593, -2.2426305] },
      { name: 'London UK', coordinates: [51.5072178, -0.1275862] },
      { name: 'Bristol UK', coordinates: [51.454513, -2.58791] },
      { name: 'York UK', coordinates: [53.9614205, -1.0739108] },
      { name: 'Liverpool UK', coordinates: [53.4083714, -2.9915726] },
      { name: 'Birmingham UK', coordinates: [52.4822694, -1.8900078] },
    ]
    within_range = [10, 20, 30, 50, 100]

    preference_attrs = application_forms.map do |form|
      {
        pool_status: 'opt_in',
        status: 'published',
        dynamic_location_preferences: true,
        candidate_id: form.candidate_id,
        application_form_id: form.id,
        training_locations: rand(100) < 20 ? 'anywhere' : 'specific', # 20% anywhere
      }
    end
    CandidatePreference.insert_all(preference_attrs)

    location_preference_attrs = CandidatePreference.all.map do |preference|
      next if preference.training_locations.nil?

      location = locations.sample
      {
        name: location[:name],
        within: within_range.sample,
        latitude: location[:coordinates].first,
        longitude: location[:coordinates].last,
        candidate_preference_id: preference.id,
      }
    end
    CandidateLocationPreference.insert_all(location_preference_attrs)

    FindACandidate::PopulatePoolWorker.perform_sync
  end
end
