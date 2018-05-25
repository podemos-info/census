# frozen_string_literal: true

# The form object that handles the data for a person
module People
  class PersonDataForm < Form
    attribute :first_name, String
    attribute :last_name1, String
    attribute :last_name2, String
    attribute :document_type, String
    attribute :document_id, String
    attribute :born_at, Date
    attribute :gender, String
    attribute :address, String
    attribute :postal_code, String
    attribute :email, String
    attribute :phone, String

    normalize :first_name, :last_name1, :last_name2, with: :whitespace
    normalize :address, :postal_code, with: :whitespace

    validates :document_type, inclusion: { in: Person.document_types.keys }, allow_blank: true
    validates :document_id, document_id: { type: :current_document_type, scope: :current_document_scope_code }, allow_nil: true
    validates :gender, inclusion: { in: Person.genders.keys }, allow_blank: true

    validates :first_name, :last_name1, :document_type, :document_id, :born_at, :gender, :address, :postal_code, :email, filled: { required: :complete_required? }

    validate :validate_document_scope

    [:document_scope, :address_scope, :scope].each do |field|
      attribute :"#{field}_id", Integer
      attribute :"#{field}_code", String

      validates field, presence: true, if: :"#{field}_required?"

      delegate :id, :code, to: field, prefix: true, allow_nil: true

      define_method field do
        field_value = instance_variable_get("@#{field}")
        unless field_value
          field_id = instance_variable_get("@#{field}_id")
          field_code = instance_variable_get("@#{field}_code")
          if field_id
            field_value = Scope.find(field_id)
          elsif field_code
            field_value = Scope.find_by(code: field_code)
          end
          instance_variable_set "@#{field}", field_value
        end
        field_value
      end

      define_method "#{field}_required?" do
        complete_required? || instance_variable_get("@#{field}_id") || instance_variable_get("@#{field}_code")
      end

      delegate :name, :full_path, :local_path, to: :"decorated_#{field}", allow_nil: true, prefix: field

      define_method "decorated_#{field}" do
        send(field)&.decorate
      end
    end

    def document_id
      if current_document_type && Person.document_types.keys.include?(current_document_type)
        Normalizr.normalize(current_document_id, :"document_#{current_document_type}")
      else
        current_document_id
      end
    end

    private

    def validate_document_scope
      errors.add :document_scope, :should_be_local if current_document_type && current_document_type != "passport" &&
                                                      current_document_scope && !current_document_scope.local?
    end

    def current_document_id
      @current_document_id ||= @document_id || person&.document_id
    end

    def current_document_type
      @current_document_type ||= document_type || person&.document_type
    end

    def current_document_scope
      @current_document_scope ||= document_scope || person&.document_scope
    end

    def current_document_scope_code
      current_document_scope&.code
    end
  end
end
