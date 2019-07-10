# frozen_string_literal: true

class PeopleMailer < ApplicationMailer
  helper_method :person

  def affiliated(person)
    self.person = person
    mail(to: person.email, subject: I18n.t("people_mailer.affiliated.subject")) if person.member?
  end

  def unaffiliated(person)
    self.person = person
    mail(to: person.email, subject: I18n.t("people_mailer.unaffiliated.subject")) unless person.member?
  end

  private

  attr_accessor :person
end
