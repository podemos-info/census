;( function( window ) {
  'use strict';

  function Header() {
    this._init();
  };

  Header.prototype._init = function() {
    this.running = false;
    this.auth_token = document.getElementsByName("csrf-token")[0].content;
    this.updateRunning();
  };

  Header.prototype.updateRunning = function() {
    this._request.abort();
    this._request.open('POST', "/jobs/running");
    this._request.setRequestHeader('X-CSRF-Token', this.auth_token);
    this._request.send();

    this._request.onload = (e) => {
      var gear = document.getElementById("user_jobs");
      var running = Number(e.target.response) > 0;
      gear.className = running ? "running" : "";
      if (this.running && !running) location.reload();
      this.running = running;

      setTimeout( () => this.updateRunning(), running ? 5000 : 60000);
    };
  };

  Header.prototype._request = new XMLHttpRequest();

  window.Header = Header;
})( window );

document.addEventListener("DOMContentLoaded", () => { new Header() });
