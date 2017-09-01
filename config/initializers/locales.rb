# frozen_string_literal: true

I18n.available_locales = [Settings.regional.locales.default] + Settings.regional.locales.available
I18n.default_locale = Settings.regional.locales.default
