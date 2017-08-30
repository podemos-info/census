# frozen_string_literal: true

# The form object that handles the data for a person
class PersonForm < Form
  mimic :person

  attribute :level, String
  attribute :first_name, String
  attribute :last_name1, String
  attribute :last_name2, String
  attribute :document_type, String
  attribute :document_id, String
  attribute :document_scope_code, String
  attribute :born_at, Date
  attribute :gender, String
  attribute :address, String
  attribute :address_scope_code, String
  attribute :postal_code, String
  attribute :email, String
  attribute :scope_code, String
  attribute :phone, String
  attribute :extra, Hash
  attribute :files, Array

  validates :level, presence: true, inclusion: { in: Person.levels }

  normalize :first_name, :last_name1, :last_name2, with: [:whitespace, :blank]
  validates :first_name, :last_name1, presence: true

  validates :document_type, inclusion: { in: Person::DOCUMENT_TYPES }, presence: true
  validates :document_id, document_id: { type: :document_type, scope: :document_scope_code }, presence: true
  validates :document_scope_code, presence: true, if: :require_document_scope?

  validates :born_at, presence: true

  validates :gender, inclusion: { in: Person::GENDERS }, presence: true

  normalize :address, :postal_code, with: :whitespace
  validates :address, :address_scope_code, :postal_code, presence: true

  validates :email, :scope_code, :phone, presence: true

  validate :files_presence

  def document_id=(value)
    super value && document_type ? Normalizr.normalize(value, :"document_#{document_type}") : value
  end

  def document_type=(value)
    super value
    self.document_id = document_id if document_id.present?
  end

  def require_document_scope?
    document_type != "dni"
  end

  def files_presence
    validates_length_of :files, minimum: (document_type == "passport" ? 1 : 2)
  end

  def document_scope
    Scope.find_by_code(document_scope_code) if document_scope_code
  end

  def scope
    Scope.find_by_code(scope_code)
  end

  def address_scope
    Scope.find_by_code(address_scope_code)
  end

  def files=(value)
    super(value.map do |file|
            tempfile = Tempfile.new("")
            tempfile.binmode
            tempfile << Base64.decode64(file[:base64_content])
            tempfile.rewind
            ActionDispatch::Http::UploadedFile.new(filename: file[:filename], type: file[:content_type], tempfile: tempfile)
          end)
  end
end
