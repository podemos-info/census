# frozen_string_literal: true

module Census
  module ActiveAdmin
    module Views
      class ChangesAttributesTable < ::ActiveAdmin::Views::AttributesTable
        builder_method :changes_table_for

        def build(obj, *attrs)
          options = attrs.extract_options!
          @changes = options[:changes] || {}
          @mode = options[:mode]
          super(obj, *attrs)
        end

        def rows(*attrs)
          attrs.each { |attr| chrow(attr) }
        end

        def chrow(field, machine: nil, change_field: field, &block)
          return if @mode == :changes && !@changes[change_field]
          if machine
            state_row(field, machine: machine, class: @changes[change_field], &block)
          else
            row(field, class: @changes[change_field], &block)
          end
        end
      end
    end
  end
end
