# frozen_string_literal: true

class ProceduresChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user

    stream_for procedure
  end

  def lock(data)
    keep_lock! if data["keep"]

    return unless data["acquire"] || data["force"]

    lock_form = Procedures::LockProcedureForm.from_params(procedure: procedure, lock_version: procedure.lock_version, force: data["force"])
    Procedures::LockProcedure.call(form: lock_form, admin: current_user)
    notify_status
  end

  def unsubscribed
    stop_all_streams

    return if keep_lock?

    unlock_form = Procedures::LockProcedureForm.from_params(procedure: procedure, lock_version: procedure.lock_version)
    Procedures::UnlockProcedure.call(form: unlock_form, admin: current_user)
    notify_status
  end

  private

  def procedure
    @procedure ||= Procedure.find(params[:procedure_id]).tap { |procedure| procedure.assign_attributes(lock_version: params[:lock_version]) }
  end

  def notify_status
    ProceduresChannel.notify_status(procedure)
  end

  def keep_lock?
    @keep_lock
  end

  def keep_lock!
    @keep_lock = true
  end

  class << self
    def notify_status(procedure)
      ProceduresChannel.broadcast_to(procedure, procedure: serialized_procedure(procedure))
    end

    private

    def serialized_procedure(procedure)
      ProcedureSerializer.new(procedure.decorate, for_channel: true).as_json
    end
  end
end
