class ProceduresChannel {
  constructor(procedure_id, lock_version) {
    let self = this;
    document.addEventListener("submit", function(event) {
      procedure_channel.keepLock();
    });

    document.addEventListener("DOMContentLoaded", function(event) {
      self.process_processing = document.getElementById("process_processing");
      if (!self.process_processing) return;

      self.procedure_status = document.getElementById("procedure_status");
      self.subscription = App.cable.subscriptions.create({ channel: "ProceduresChannel", procedure_id: procedure_id, lock_version: lock_version}, {
        connected: function() {
          self.lock();
        },
        received: function(data) {
          self.procedure = data["procedure"];
          if (self.procedure["state"] != "pending") {
            window.location.reload();
            return;
          }
          let processing_by_id = self.procedure["processing_by_id"];
          self.process_processing.setAttribute("data-processing-by-id", processing_by_id);
          if (processing_by_id == null) self.lock();
          self.updateProcessProcessing();
        }
      })
    });
  }

  updateProcessProcessing() {
    var template = this.procedure_status.getAttribute("data-template");
    this.procedure_status.innerHTML = Object.keys(this.procedure).reduce((acum, attr) => acum.replace(`@{${attr}}`, this.procedure[attr]), template);

    if (this.process_processing.getAttribute("data-current-admin") == this.process_processing.getAttribute("data-processing-by-id")) {
      this.process_processing.className = "unlocked";
    } else {
      this.process_processing.className = "locked";
    }
  }

  lock() {
    this.subscription.perform("lock", { acquire: true });
  }

  keepLock() {
    this.subscription.perform("lock", { keep: true });
  }

  forceLock() {
    this.subscription.perform("lock", { force: true });
  }
}
