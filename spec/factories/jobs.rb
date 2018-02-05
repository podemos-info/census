# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    job_id { generate(:job_id) }
    job_type "ProcessOrdersBatchJob"
    status "enqueued"
    result nil
    user { create(:admin) }

    after :build do |job|
      job.job_objects << build(:job_object, job: job)
      job.messages << build(:job_message, job: job)
      job.messages << build(:job_message, :raw, job: job)
    end

    trait :running do
      status "running"
    end
  end

  factory :job_object, class: :"active_job_reporter/job_object" do
    job { create(:job) }
    object { create(:orders_batch) }
  end

  factory :job_message, class: :"active_job_reporter/job_message" do
    job { create(:job) }
    message_type "user"
    message { { key: "process_orders_batch_job.order_ok", related: [job.job_objects.first.object.orders.first.to_gid_param] } }

    trait :raw do
      message { { raw: "A raw message" } }
    end
  end
end
