module FindAPIHelper
  def stub_find_api_provider_200(provider_code: 'ABC', provider_name: 'Dummy Provider', course_code: 'X130', site_code: 'X', findable: true)
    stub_find_api_provider(provider_code)
      .to_return(
        status: 200,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: {
          'data': {
            'id': '1',
            'type': 'providers',
            'attributes': {
              'provider_name': provider_name,
              'provider_code': provider_code,
            },
            'relationships': {
              'sites': {
                'data': [
                  { 'id': '1', 'type': 'sites' },
                ],
              },
              'courses': {
                'data': [
                  { 'id': '1', 'type': 'courses' },
                ],
              },
            },
          },
          'included': [
            {
              'id': '1',
              'type': 'sites',
              'attributes': {
                'code': site_code,
                'location_name': 'Main site',
              },
            },
            {
              'id': '1',
              'type': 'courses',
              'attributes': {
                'course_code': course_code,
                'name': 'Primary',
                'level': 'primary',
                'start_date': 'September 2019',
                'findable?': findable,
                'accrediting_provider': nil,
              },
              'relationships': {
                'sites': {
                  'data': [
                    { 'id': '1', 'type': 'sites' },
                  ],
                },
              },
            },
          ],
          'jsonapi': { 'version': '1.0' },
        }.to_json,
      )
  end

  def stub_find_api_provider_200_with_accrediting_provider(provider_code: 'ABC', provider_name: 'Dummy Provider', course_code: 'X130', site_code: 'X', accrediting_provider_code: 'XYZ', accrediting_provider_name: 'Dummy Accrediting Provider', findable: true)
    stub_find_api_provider(provider_code)
      .to_return(
        status: 200,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: {
          'data': {
            'id': '1',
            'type': 'providers',
            'attributes': {
              'provider_name': provider_name,
              'provider_code': provider_code,
            },
            'relationships': {
              'sites': {
                'data': [
                  { 'id': '1', 'type': 'sites' },
                ],
              },
              'courses': {
                'data': [
                  { 'id': '1', 'type': 'courses' },
                ],
              },
            },
          },
          'included': [
            {
              'id': '1',
              'type': 'sites',
              'attributes': {
                'code': site_code,
                'location_name': 'Main site',
              },
            },
            {
              'id': '1',
              'type': 'courses',
              'attributes': {
                'course_code': course_code,
                'name': 'Primary',
                'level': 'primary',
                'start_date': 'September 2019',
                'findable?': findable,
                'accrediting_provider': {
                  'provider_name': accrediting_provider_name,
                  'provider_code': accrediting_provider_code,
                },
              },
              'relationships': {
                'sites': {
                  'data': [
                    { 'id': '1', 'type': 'sites' },
                  ],
                },
              },
            },
          ],
          'jsonapi': { 'version': '1.0' },
        }.to_json,
      )
  end

private

  def stub_find_api_provider(provider_code)
    stub_request(:get, ENV.fetch('FIND_BASE_URL') +
      'recruitment_cycles/2020' \
      "/providers/#{provider_code}?include=sites,courses.sites")
  end
end
