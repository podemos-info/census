//= require vanilla-modal/index

;( function( window ) {
  'use strict';

  var modalContainer;

  function DataPicker() {
    this._init();
  };

  DataPicker.prototype._init = function() {
    if (!modalContainer) {
      modalContainer = this._createModalContainer();
      document.body.appendChild(modalContainer);
      this.modal = new VanillaModal.default();
    }

    var self = this,
        pickers = document.getElementsByClassName('data-picker');

    Array.from(pickers).forEach(function(el, index, array){
      var value = el.getAttribute('data-picker-value'),
          text  = el.getAttribute('data-picker-text'),
          name  = el.getAttribute('data-picker-name');
      var id    = name.replace(/[^a-zA-Z0-9]/g, "_");
      el.innerHTML = '<input class="picker-value" type="hidden" name="'+name+'" value="'+value+'"/>\
                      <span class="picker-text">'+text+'</span>\
                      <div id="'+id+'" class="picker-container"/>';
      el.addEventListener('click', function(e) {
        e.preventDefault();
        self.openPicker(this);
      });
    });
  };

  DataPicker.prototype._createModalContainer = function() {
    var container = document.createElement('div');
    container.className = 'modal';
    container.innerHTML = '<div class="modal-inner"><a data-modal-close>&times;</a><div class="modal-content"></div></div>';
    return container;
  };

  DataPicker.prototype.openPicker = function(picker) {
    this.current = {
                      picker: picker,
                      value: picker.getElementsByClassName('picker-value')[0],
                      text: picker.getElementsByClassName('picker-text')[0],
                      container: picker.getElementsByClassName('picker-container')[0],
                    };

    this.browse(picker.getAttribute('data-picker-url'));
  };

  DataPicker.prototype.browse = function(url) {
    this._request.abort();
    this._request.open('GET', url);
    this._request.send();

    var self = this;
    this._request.onload = function(e) {
      modalContainer.getElementsByClassName("modal-content")[0].innerHTML = "";
      self.current.container.innerHTML = e.target.response;
      self._handleNavigation();
      self.modal.open('#'+self.current.container.id);
    };
  };

  DataPicker.prototype._handleNavigation = function() {
    var self = this,
        anchors = self.current.container.getElementsByTagName('a');
    Array.from(anchors).forEach(function(el, index, array){
      el.addEventListener('click', function(e) {
        if (el.getAttribute('data-modal-close')) return;
        e.preventDefault();
        var choose_value = el.getAttribute('data-picker-choose-value'),
            choose_text = el.getAttribute('data-picker-choose-text'),
            choose_link = el.getAttribute('href');
        if (choose_value && choose_text)
          self.choose(choose_link, choose_value, choose_text);
        else
          self.browse(choose_link);
      });
    });
  };

  DataPicker.prototype.choose = function(link, value, text) {
    this.current.picker.setAttribute('data-picker-url', link);
    this.current.value.setAttribute('value', value);
    this.current.text.innerHTML = text;
    this.modal.close();
  };

  DataPicker.prototype.current = null;
  DataPicker.prototype._request = new XMLHttpRequest();

  window.DataPicker = DataPicker;
})( window );

document.addEventListener("DOMContentLoaded", function() { new DataPicker() });