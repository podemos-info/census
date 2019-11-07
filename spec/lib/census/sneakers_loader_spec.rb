# frozen_string_literal: true

require "rails_helper"

describe Census::SneakersLoader do
  describe "#create_workers" do
    subject(:loader) { described_class.create_workers(path) }

    let(:path) { File.expand_path("app/jobs/*_job.rb", Rails.root) }

    it "registers workers for all queues" do
      expect { subject } .to change { ActiveJob::QueueAdapters::SneakersAdapter::JobWrapper.descendants.map(&:queue_name).sort }
        .from([])
        .to(%w(finances mailers payments procedures))
    end
  end
end
