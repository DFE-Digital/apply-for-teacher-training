require 'rails_helper'

RSpec.describe 'Airbyte field check' do
  it 'identifies if any attributes are missing from the airbyte stream config' do
    # DfE::Analytics::Fields.check! does not run in test environment
    # This test has been pieced together from the dfe-analytics gem documentation

    # retrieve the allowlist from DfE Analytics (config/analytics.yml)
    allowlist = DfE::Analytics::Fields.allowlist.merge(
      DfE::Analytics::AirbyteStreamConfig::AIRBYTE_HEARTBEAT_ENTITY_ATTRIBUTES,
    ).transform_values(&:uniq)

    # read the airbyte stream config JSON file
    airbyte_stream_config = JSON.parse(
      File.read('terraform/aks/workspace_variables/airbyte_stream_config.json'),
    ).deep_symbolize_keys

    # transform the airbyte stream config JSON file into a hash
    cursor_fields = DfE::Analytics::AirbyteStreamConfig::CURSOR_FIELD
    airbyte_fields = DfE::Analytics::AirbyteStreamConfig::AIRBYTE_FIELDS

    transformed_airbyte_stream_config = airbyte_stream_config.dig(:configurations, :streams).each_with_object({}) do |stream, memo|
      stream_name = stream[:name]
      fields = stream[:selectedFields].map { |field| field[:fieldPath].first }
      memo[stream_name] = fields - cursor_fields - airbyte_fields
    end.deep_symbolize_keys

    # compare the lists
    expect(
      DfE::Analytics::Fields.diff_between(
        allowlist,
        transformed_airbyte_stream_config,
      ),
    ).to eq({})
  end
end
