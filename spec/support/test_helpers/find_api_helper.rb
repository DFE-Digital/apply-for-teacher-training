module FindAPIHelper
  def stub_find_api_provider_200(provider_code: 'ABC', provider_name: 'Dummy Provider', course_code: 'X130', site_code: 'X', findable: true, study_mode: 'full_time')
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
                'address1': 'Gorse SCITT ',
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
              },
            },
          ],
          'jsonapi': { 'version': '1.0' },
        }.to_json,
      )
  end

  def stub_find_api_provider_200_with_accrediting_provider(provider_code: 'ABC', provider_name: 'Dummy Provider', course_code: 'X130', site_code: 'X', accrediting_provider_code: 'XYZ', accrediting_provider_name: 'Dummy Accrediting Provider', findable: true, study_mode: 'full_time')
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
              },
            },
          ],
          'jsonapi': { 'version': '1.0' },
        }.to_json,
      )
  end

  def stub_find_api_provider_200_with_multiple_sites(provider_code: 'ABC', provider_name: 'Dummy Provider', course_code: 'X130', findable: true, study_mode: 'full_time_or_part_time')
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
      "/providers/#{provider_code}?include=sites,courses.sites")
  end
end
