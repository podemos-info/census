# frozen_string_literal: true

module Issues
  # A command to create, update or fix issues for a person
  class CheckPersonIssues < CheckIssues
    # Public: Initializes the command.
    #
    # person - Person with data to search for
    # admin - The admin user triggered the check
    def initialize(person:, admin:)
      @person = person
      @admin = admin
    end

    private

    attr_reader :person, :admin

    def has_issue?
      people.size > 1
    end

    def issue
      @issue ||= ::IssuesForDocument.for(document_type: person.document_type, document_scope_id: person.document_scope_id, document_id: person.document_id)
                                    .merge(::IssuesNonFixed.for).first || Issue.new(
                                      issue_type: :duplicated_document,
                                      role: Admin.roles[:lopd],
                                      level: :medium,
                                      assigned_to: nil,
                                      information: {
                                        document_type: person.document_type,
                                        document_scope_id: person.document_scope_id,
                                        document_id: person.document_id
                                      },
                                      fixed_at: nil
                                    )
    end

    def update_affected_objects
      issue.people = people
    end

    def people
      @people ||= ::PeopleWithDuplicatedDocument.for(document_type: person.document_type, document_scope_id: person.document_scope_id, document_id: person.document_id)
    end
  end
end
