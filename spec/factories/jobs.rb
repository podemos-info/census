# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    job_id { generate(:job_id) }
    job_type { "ProcessOrdersBatchJob" }
    status { "enqueued" }
    result { nil }
    user { create(:admin) }

    after :build do |job|
      job.job_objects << build(:job_object, job: job)
      job.job_objects << build(:job_object, :nonexistent_object, job: job)
      job.messages << build(:job_message, job: job)
      job.messages << build(:job_message, :raw, job: job)
      job.messages << build(:job_message, :raw_related, job: job)
    end

    trait :running do
      status { "running" }
    end

    trait :finished do
      status { "finished" }
      result { "ok" }
    end
  end

  factory :job_object, class: :"active_job_reporter/job_object" do
    job { create(:job) }
    object { create(:orders_batch) }

    trait :nonexistent_object do
      after :build do |job_object|
        job_object.object.delete
      end
    end
  end

  factory :job_message, class: :"active_job_reporter/job_message" do
    job { create(:job) }
    message_type { "user" }
    message { { key: "process_orders_batch_job.order_ok", related: job.job_objects.first.object.orders.map(&:to_gid_param) } }

    trait :raw_related do
      message { { key: "process_orders_batch_job.order_ok", related: ["A raw related message"] } }
    end

    trait :raw do
      message { { raw: "A raw message" } }
    end
  end
end
