document.addEventListener("DOMContentLoaded", function(event) {
  App.cable.subscriptions.create({ channel: "AdminsChannel"}, {
    connected: function() {
      this.perform("status");
    },
    received: function(data) {
      document.getElementById("admin_jobs").className = data["admin"]["count_running_jobs"] > 0 ? "running" : "";
      document.getElementById("admin_issues").className = data["admin"]["count_unread_issues"] > 0 ? "unread" : "";
    }
  })
});