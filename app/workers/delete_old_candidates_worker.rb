class DeleteOldCandidatesWorker < ApplicationJob
  def perform
    # candidates = Candidate.where('last_signed_in_at < ?', 7.years.ago).find_in_batches(&:destroy_all)

    analytics_tables = YAML.load_file('config/analytics.yml').fetch('shared').keys
    candidate = Candidate.find(59)
    sql_keys = candidate.test_sql
    rails_keys = candidate.test_delete

    shared_keys = sql_keys.keys & rails_keys.keys
    merged_tables = sql_keys.merge(rails_keys).except(shared_keys).except(analytics_tables)
    puts ''
    puts ''
    puts ''
    puts ''
    puts merged_tables
    # compact?

    # create the delete table
    # go through the records that will be deleted
    # check with analytics
    # save the table and id in the jsonb column
    #
    # Do these in the same transaction
    # create deletion table
    # delete
  end
end
