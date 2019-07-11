# frozen_string_literal: true

class PeopleMailer < ApplicationMailer
  def affiliated
    @person = params[:person]
    mail(to: @person.email, subject: I18n.t("people_mailer.affiliated.subject")) if @person.member?
  end

  def unaffiliated
    @person = params[:person]
    mail(to: @person.email, subject: I18n.t("people_mailer.unaffiliated.subject")) unless @person.member?
  end
end
