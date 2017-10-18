# frozen_string_literal: true

class DataPickerInput < ActiveAdminAddons::InputBase
  def render_custom_input
    value = object.send(method)
    text = object.send(options[:text] || :to_s)
    concat label_html
    concat "<div class='data-picker' data-picker-name='#{object_name}[#{method}]' data-picker-url='#{options[:url]}'
            data-picker-value='#{value}' data-picker-text='#{text}'></div>"
  end

  def load_control_attributes
    load_data_attr(:root, default: nil)
  end
end
