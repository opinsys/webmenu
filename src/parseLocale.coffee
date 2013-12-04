
# Parse system locale, eg. fi_FI.UTF-8 to object
parseLocale = (systemLocale) ->
  ob = {}

  [locale, encoding] =  systemLocale.split(".")
  ob.locale = locale
  ob.encoding = encoding

  [lang, country] = locale.split("_")
  ob.lang = lang
  ob.country = country

  ob.original = systemLocale
  return ob

module.exports = parseLocale
