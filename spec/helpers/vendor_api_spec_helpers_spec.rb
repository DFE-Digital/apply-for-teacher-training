require 'rails_helper'

RSpec.describe VendorApiSpecHelpers do
  subject(:dummy_class) { Class.new { include VendorApiSpecHelpers } }

  it 'works' do
    spec = { a: 1 }
    expect(dummy_class.new.parse_openapi_json_schema(spec)).to eq "boo"
  end
end
