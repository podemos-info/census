# frozen_string_literal: true

I18n.available_locales = [Settings.locales.default] + Settings.locales.available
I18n.default_locale = Settings.locales.default
