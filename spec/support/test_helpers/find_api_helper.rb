module FindAPIHelper
  def stub_find_api_provider_200(
    provider_code: 'ABC',
    provider_name: 'Dummy Provider',
    course_code: 'X130',
    site_code: 'X',
    findable: true,
    study_mode: 'full_time',
    description: 'PGCE with QTS full time',
    financial_support: 'You get nothing!',
    start_date: Time.zone.local(2020, 10, 31),
    applications_open_from: Time.zone.local(2019, 9, 1),
    course_length: 'OneYear',
    region_code: 'north_west',
    site_address_line2: 'C/O The Bruntcliffe Academy'
  )
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
              'region_code': region_code,
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
                'address1': 'Gorse SCITT ',
                'address2': site_address_line2,
                'address3': 'Bruntcliffe Lane',
                'address4': 'MORLEY, LEEDS',
                'postcode': 'LS27 0LZ',
              },
            },
            {
              'id': '1',
              'type': 'courses',
              'attributes': {
                'course_code': course_code,
                'name': 'Primary',
                'level': 'primary',
                'study_mode': study_mode,
                'description': description,
                'financial_support': financial_support,
                'start_date': start_date,
                'applications_open_from': applications_open_from,
                'course_length': course_length,
                'recruitment_cycle_year': '2020',
                'findable?': findable,
                'accrediting_provider': nil,
              },
              'relationships': {
                'sites': {
                  'data': [
                    { 'id': '1', 'type': 'sites' },
                  ],
                },
                'site_statuses': {
                  'data': [
                    { 'id': '222', 'type': 'site_statuses' },
                  ],
                },
              },
            },
            {
              'id': '222',
              'type': 'site_statuses',
              'attributes': {
                'vac_status': 'full_time_vacancies',
                'publish': 'published',
                'status': 'running',
                'has_vacancies?': true,
              },
              'relationships': {
                'site': {
                  'data': {
                    'type': 'sites',
                    'id': '1',
                  },
                },
              },
            },
          ],
          'jsonapi': { 'version': '1.0' },
        }.to_json,
      )
  end

  def stub_find_api_provider_200_with_accrediting_provider(
    provider_code: 'ABC',
    provider_name: 'Dummy Provider',
    course_code: 'X130',
    site_code: 'X',
    accrediting_provider_code: 'XYZ',
    accrediting_provider_name: 'Dummy Accrediting Provider',
    findable: true,
    study_mode: 'full_time',
    description: 'PGCE with QTS full time',
    financial_support: 'You get nothing!',
    start_date: Time.zone.local(2020, 10, 31),
    applications_open_from: Time.zone.local(2019, 9, 1),
    course_length: 'OneYear',
    region_code: 'north_west'
  )
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
              'region_code': region_code,
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
                'address1': 'Gorse SCITT',
                'address2': 'C/O The Bruntcliffe Academy',
                'address3': 'Bruntcliffe Lane',
                'address4': 'MORLEY, LEEDS',
                'postcode': 'LS27 0LZ',
              },
            },
            {
              'id': '1',
              'type': 'courses',
              'attributes': {
                'course_code': course_code,
                'name': 'Primary',
                'level': 'primary',
                'study_mode': study_mode,
                'description': description,
                'financial_support': financial_support,
                'start_date': start_date,
                'applications_open_from': applications_open_from,
                'course_length': course_length,
                'recruitment_cycle_year': '2020',
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
                'site_statuses': {
                  'data': [
                    { 'id': '222', 'type': 'site_statuses' },
                  ],
                },
              },
            },
            {
              'id': '222',
              'type': 'site_statuses',
              'attributes': {
                'vac_status': 'full_time_vacancies',
                'publish': 'published',
                'status': 'running',
                'has_vacancies?': true,
              },
              'relationships': {
                'site': {
                  'data': {
                    'type': 'sites',
                    'id': '1',
                  },
                },
              },
            },
          ],
          'jsonapi': { 'version': '1.0' },
        }.to_json,
      )
  end

  def stub_find_api_provider_200_with_multiple_sites(
    provider_code: 'ABC',
    provider_name: 'Dummy Provider',
    course_code: 'X130',
    findable: true,
    study_mode: 'full_time_or_part_time',
    description: 'PGCE with QTS full time',
    financial_support: 'You get nothing!',
    start_date: Time.zone.local(2020, 10, 31),
    applications_open_from: Time.zone.local(2019, 9, 1),
    course_length: 'OneYear',
    region_code: 'north_west'
  )
    response_hash = {
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: {
        'data': {
          'id': '1',
          'type': 'providers',
          'attributes': {
            'provider_name': provider_name,
            'provider_code': provider_code,
            'region_code': region_code,
          },
          'relationships': {
            'sites': {
              'data': [
                { 'id': '1', 'type': 'sites' },
                { 'id': '2', 'type': 'sites' },
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
              'code': 'X',
              'location_name': 'Main site',
              'address1': 'Gorse SCITT ',
              'address2': 'C/O The Bruntcliffe Academy',
              'address3': 'Bruntcliffe Lane',
              'address4': 'MORLEY, Leeds',
              'postcode': 'LS27 0LZ',
            },
          },
          {
            'id': '2',
            'type': 'sites',
            'attributes': {
              'code': 'Y',
              'location_name': 'Secondary site',
              'address1': 'Gorse SCITT ',
              'address2': 'C/O The Bruntcliffe Academy',
              'address3': 'Another Lane',
              'address4': 'MORLEY, Leeds',
              'postcode': 'LS27 5HT',
            },
          },
          {
            'id': '1',
            'type': 'courses',
            'attributes': {
              'course_code': course_code,
              'name': 'Primary',
              'level': 'primary',
              'study_mode': study_mode,
              'description': description,
              'financial_support': financial_support,
              'start_date': start_date,
              'applications_open_from': applications_open_from,
              'course_length': course_length,
              'recruitment_cycle_year': '2020',
              'findable?': findable,
              'accrediting_provider': nil,
            },
            'relationships': {
              'sites': {
                'data': [
                  { 'id': '1', 'type': 'sites' },
                  { 'id': '2', 'type': 'sites' },
                ],
              },
              'site_statuses': {
                'data': [
                  { 'id': '222', 'type': 'site_statuses' },
                  { 'id': '223', 'type': 'site_statuses' },
                ],
              },
            },
          },
          {
            'id': '222',
            'type': 'site_statuses',
            'attributes': {
              'vac_status': 'full_time_vacancies',
              'publish': 'published',
              'status': 'running',
              'has_vacancies?': true,
            },
            'relationships': {
              'site': {
                'data': {
                  'type': 'sites',
                  'id': '1',
                },
              },
            },
          },
          {
            'id': '223',
            'type': 'site_statuses',
            'attributes': {
              'vac_status': 'full_time_vacancies',
              'publish': 'published',
              'status': 'running',
              'has_vacancies?': true,
            },
            'relationships': {
              'site': {
                'data': {
                  'type': 'sites',
                  'id': '2',
                },
              },
            },
          },
        ],
        'jsonapi': { 'version': '1.0' },
      }.to_json,
    }
    stub_find_api_provider(provider_code).to_return response_hash
  end

  def stub_find_api_all_providers_200(provider_data)
    data = provider_data.each_with_index.map do |attributes, index|
      {
        id: index.to_s,
        type: 'providers',
        attributes: {
          provider_code: attributes[:provider_code],
          provider_name: attributes[:name],
          recruitment_cycle_year: '2020',
        },
        relationships: {
          courses: {
            meta: {
              count: 1,
            },
          },
        },
      }
    end

    stub_find_api_all_providers
      .to_return(
        status: 200,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: {
          data: data,
          jsonapi: { version: '1.0' },
        }.to_json,
      )
  end

  def stub_find_api_course_200(provider_code, course_code, course_name)
    stub_find_api_course(provider_code, course_code)
      .to_return(
        status: 200,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: {
          'data' => {
            'id' => '1',
            'type' => 'courses',
            'attributes' => {
              'course_code' => course_code,
              'name' => course_name,
              'provider_code' => provider_code,
            },
          },
          'jsonapi' => { 'version' => '1.0' },
        }.to_json,
      )
  end

  def stub_find_api_course_timeout(provider_code, course_code)
    stub_find_api_course(provider_code, course_code)
      .to_timeout
  end

  def stub_find_api_course_404(provider_code, course_code)
    stub_find_api_course(provider_code, course_code)
      .to_return(status: 404)
  end

  def stub_find_api_course_503(provider_code, course_code)
    stub_find_api_course(provider_code, course_code)
      .to_return(status: 503)
  end

  def stub_find_api_course(provider_code, course_code)
    stub_request(:get, ENV.fetch('FIND_BASE_URL') +
      'recruitment_cycles/2020' \
      "/providers/#{provider_code}" \
      "/courses/#{course_code}")
  end

private

  def stub_find_api_all_providers
    stub_request(
      :get,
      "#{ENV.fetch('FIND_BASE_URL')}recruitment_cycles/2020/providers",
    )
  end

  def stub_find_api_provider(provider_code)
    stub_request(:get, ENV.fetch('FIND_BASE_URL') +
      'recruitment_cycles/2020' \
      "/providers/#{provider_code}?include=sites,courses.sites,courses.site_statuses.site")
  end
end
