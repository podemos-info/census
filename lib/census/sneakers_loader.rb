# frozen_string_literal: true

module Census::SneakersLoader
  def self.create_workers(path)
    Dir.glob(path).each do |job_file|
      require job_file
    end

    queues = ApplicationJob.descendants.map(&:queue_name).uniq + %w(mailers)
    queues.each do |queue_name|
      Object.const_set("#{queue_name}_worker".classify, Class.new(ActiveJob::QueueAdapters::SneakersAdapter::JobWrapper) do
        include Sneakers::Worker
        from_queue queue_name
      end)
    end
  end
end
