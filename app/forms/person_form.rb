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
  attribute :scope_code, String
  attribute :email, String
  attribute :phone, String
  attribute :extra, Hash
  attribute :document_files, Array

  validates :level, presence: true, inclusion: { in: Person.levels }
  validates :first_name, :last_name1, :last_name2, presence: true
  validates :document_type, :document_id, presence: true
  validates :document_type, inclusion: { in: Person::DOCUMENT_TYPES }
  validates :document_scope_code, presence: true, if: :require_document_scope?
  validates :born_at, :gender, presence: true
  validates :gender, inclusion: { in: Person::GENDERS }
  validate :document_files_presence

  def require_document_scope?
    document_type != "dni"
  end

  def document_files_presence
    validates_length_of :document_files, minimum: (document_type == "passport" ? 1 : 2)
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

  def files
    @files ||= document_files.map do |file|
      tempfile = Tempfile.new("")
      tempfile.binmode
      tempfile << Base64.decode64(file[:base64_content])
      tempfile.rewind
      ActionDispatch::Http::UploadedFile.new(filename: file[:filename], type: file[:content_type], tempfile: tempfile)
    end
  end
end
