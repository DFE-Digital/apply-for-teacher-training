require 'google/cloud/bigquery'

module DfE
  module Bigquery
    class Table
      def self.client
        ::DfE::Bigquery.client
      end
    end
  end
end
