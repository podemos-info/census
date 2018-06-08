# frozen_string_literal: true

module People
  # A command to create a document verification procedure for a person.
  class CreateDocumentVerification < PersonCommand
    # Public: Initializes the command.
    # form - A form object with the params.
    # admin - The admin user creating the document verification for the person.
    def initialize(form:, admin: nil)
      @form = form
      @admin = admin
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the procedure wasn't valid and we couldn't proceed.
    # - :error if there is any problem saving the new record.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless form&.valid?

      result = save_document_verification

      broadcast result, document_verification: document_verification

      ::UpdateProcedureJob.perform_later(procedure: document_verification, admin: admin) if result == :ok
    end

    private

    def save_document_verification
      Person.transaction do
        document_verification.save!
        if person.may_receive_verification?
          person.receive_verification!
          ::People::ChangesPublisher.full_status_changed!(person)
        end
        :ok
      end || :error
    end

    attr_reader :form, :admin
    delegate :person, to: :form

    def document_verification
      @document_verification ||= begin
        procedure_for(person, ::Procedures::DocumentVerification) do |procedure|
          procedure.attachments.clear
          form.files.each do |file|
            procedure.attachments.build(file: file)
          end
        end
      end
    end
  end
end
