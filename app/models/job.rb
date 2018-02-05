# frozen_string_literal: true

class Job < ActiveRecord::Base
  include ActiveJobReporter::JobConcern
end
