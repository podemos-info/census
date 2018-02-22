# frozen_string_literal: true

class Job < ApplicationRecord
  include ActiveJobReporter::JobConcern
end
