require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')

def set_headers(api_key)
  header [
    { name: 'Content-Type', value: 'application/json' },
    { name: 'Authorization', value: "Bearer #{api_key}" },
  ]
end

# Expected Oct usage per hour:
#   71 SRS systems polling every hour for 90 days of data
test do
  random_timer 1000, 900000 # this is 4x that

  # Section below must have 71 api keys, each belonging to a different provider
  %w[
    Ze4rL4Nz8hzm_t7aJdBG BG8Fd1jW2JCs3J6fCzzs yKbesemkdx3hM4hTRu1C pwkZVZWa9tVk393htbnT
    Y3NpsFdmymsnZ6VzFt4M 1v2qjH-WhN88GhyUD9XG YWA6iXCjQjspU7LjriWA kzwcj6_k_LdCGpGWR2t5
    VGBukaCmfcyQzVYbMXkt Pz37P_-nfE_dAR23cUaH JXQsKX_xt9-UymkJJskZ AskVr7zn9aqU81sFBTg7
    S5QAmftkyjQBxY3aCfwR sWQ-vsX1xyUMqAhbUJBg F1J1y9keyHTG-nNRveex rqn7vxdxspCRGu22KdU4
    pDqPLmWKRKiLJ_eoAcbi xqD73UWiHRKfFSpzsVse d7t_bEP-VQAAX-Jn4QYf dRhH5t7bFjd2xjCFK_Gi
    Fhbx-Lw5furyHiq4Y6Jx Djszj57PMjbJSixQrMB5 5xYfJmxy5soijFEgt2kS C73PQGBRkWrzi3K3QDRx
    cLipzwEFa5aZtsftcyuz -gmi8s5-EFZm1NVjX4tb H9xRezgjhtPV4vHekEBm b2VD8tVFAf4DBYqPRW7R
    1ymXFa5JLMy48yk8nfpo 5ADYN5bx9psxmUncsbgC n_3qhmyMGKfjuzsUPCfq Ap7W7jpf-4rNUxajoqRd
    VnKExzTJhFZrC6VRQdUa R_R5H3TUdamY_BQaZ-iP LRrpz1T14AoGQmgYx9Us K2DmpxowvzACatPod954
    RU8cvyU2zCho2MqnKqT6 WGrnxEf7ve865DQssBRY T7LEmbskCAF_iXn-HxNo XycE5hVGs-kygxJcLyeQ
    xiQD7LTx5Lpjq5whTfYU x_E29nDFybnhZ-yGZZ-Z DYyZzJYFHY51fP5SsVHQ 17EKux-mKM-27MfMs1fB
    b62f_KxBohDUyUQWz2Yd teu5kTxNioHuDMwSuPT1 hxcC2HxZcrZpqACwvshP q8feJSgxb4Uy9evr3xjX
    ZT3g-H2eQmLJttYu9ZrE J-8i-zhxzxZTuisYB6yr 3XpPv6PVnTf-s_F5Wcig X_yMBMyXdDNWvDnmzCju
    XMCzFb2MokKMcSD4n4a9 H__7vQyptW_ibtCLoHbs MuptqFe1UptZRK5kbTWt 8BbRkVEC4y5y5RGqhr-Z
    yxFw6ukJFSzygyMv9sXP DxeRM-dz_4mw_69ZioCH WszpjMzdv7s84dpbEgog FsLTWQwTM5UcKqbnQzzp
    cWzXTqL1mbndSp31khkQ XLZWLQA7E3rRGys3jDAL Rx9so9s5aNQqFUkvbkEz erf3Cz982m3nYas1jcUq
    RG5wzV3K1zEx3JVz84Rx ekXu2tjgtJVSKtfyGPP9 sWi2j2siVXvc_NL6Hiam TTxwCzaWJhHeb3ux1TXq
    6EFn5ZRhFUwTELxG72bo FC8_dFugs-gXDU-__B3r oujZY_1YeyfWCiwoYzdx
  ].each do |api_key|

    # Sync applications (last 90 days) once every hour
    threads count: 1, continue_forever: true, duration: 3600 do
      set_headers api_key

      params = { since: (Time.now - 7776000).strftime('%Y-%m-%dT%H:%M:%S.%L%z') }
      visit name: 'API Sync applications',
        url: BASEURL + '/api/v1/applications',
        raw_body: params.to_json do
          with_xhr
        end
    end

    # Make offer
    threads count: 1, continue_forever: true, duration: 3600 do
      set_headers api_key

      params = { since: (Time.now - 7776000).strftime('%Y-%m-%dT%H:%M:%S.%L%z') }
      visit name: 'API Sync applications',
        url: BASEURL + '/api/v1/applications',
        raw_body: params.to_json do
          extract name: 'last_application_id', json: '$.data[-1].id'
          with_xhr
        end

      offer_payload = {
        data: {
          conditions: [
            'Completion of subject knowledge enhancement',
            'Completion of professional skills test'
          ]
        },
        meta: {
          attribution: {
            full_name: 'Jane Smith',
            email: 'jane.smith@example.com',
            user_id: '12345'
          },
          timestamp: (Time.now - 7776000).strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        }
      }

      submit name: 'API Make offer',
        url: BASEURL + '/api/v1/applications/${last_application_id}/offer',
        raw_body: offer_payload.to_json do
          with_xhr
        end
    end
  end
end.jmx
