namespace :shopify_gateway do
  task enqueue_job_for_pulling_store_settings: :environment do
    Channel.active.each(&:enqueue_job_for_pulling_store_settings)
  end
end
