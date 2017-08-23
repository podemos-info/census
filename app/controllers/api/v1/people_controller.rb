# frozen_string_literal: true

module Api
  class V1::PeopleController < ApiController
    def create
      @person = Person.new(person_params)
      RegisterPerson.call(@person, params[:level], files_params) do
        on(:invalid) do
          render json: @person.errors, status: :unprocessable_entity
        end
        on(:ok) do
          render json: @person, status: :created
        end
      end
    end

    def change_membership_level
      @person = Person.find_by("extra ->> 'participa_id' = ?", params[:id])
      ChangeMembershipLevel.call(@person, params[:level]) do
        on(:invalid) do
          render json: @person.errors, status: :unprocessable_entity
        end
        on(:ok) do
          render json: @person, status: :accepted
        end
      end
    end

    private

    def person_params
      params.require(:person).permit :first_name, :last_name1, :last_name2, :document_type, :document_id, :born_at,
                                     :gender, :address, :address_scope_code, :postal_code, :scope_code, :email,
                                     :phone, extra: [:participa_id]
    end

    def files_params
      file_params = [:filename, :content_type, :base64_content]
      params.require(:person).permit(document_file1: file_params, document_file2: file_params).to_h.map do |_, file|
        tempfile = Tempfile.new("")
        tempfile.binmode
        tempfile << Base64.decode64(file[:base64_content])
        tempfile.rewind
        ActionDispatch::Http::UploadedFile.new(filename: file[:filename], type: file[:content_type], tempfile: tempfile)
      end
    end
  end
end
