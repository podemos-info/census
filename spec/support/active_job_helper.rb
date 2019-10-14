# frozen_string_literal: true

module ActiveJobHelper
  def job_for(object)
    ActiveJobReporter::JobObject.find_by(object: object)&.job
  end
end

RSpec.configure do |config|
  config.include ActiveJob::TestHelper
  config.include ActiveJobHelper, type: :job
end
