
fs = require "fs"
path = require "path"
gettextParser = require "gettext-parser"

parseLocale = require "./parseLocale"


defaultSearchPaths = [
    # "/usr/share/locale-langpack/sv/LC_MESSAGES/"
    "/usr/share/locale-langpack"
]


class GettextWrap

    constructor: (locale, searchPaths=defaultSearchPaths) ->
        @lang = parseLocale(locale)
        @filesRead = {}
        @searchPaths = []

        searchPaths.forEach (sp) =>
            @searchPaths.push("#{ sp }/#{ @lang.lang }/LC_MESSAGES")
            if @lang.country and @lang.encoding
                @searchPaths.push("#{ sp }/#{ @lang.lang }_#{ @lang.country }.#{ @lang.encoding }/LC_MESSAGES")
            if @lang.country
                @searchPaths.push("#{ sp }/#{ @lang.lang }_#{ @lang.country }/LC_MESSAGES")
            if @lang.encoding
                @searchPaths.push("#{ sp }/#{ @lang.lang }.#{ @lang.encoding }/LC_MESSAGES")


    translate: (domain, str, retry=false) ->

        for sp in @searchPaths
            moPath = "#{ sp }/#{ domain }.mo"
            try
                data = fs.readFileSync(moPath)
            catch err
                if err.code is "ENOENT"
                    continue
                else
                    throw err

            trans = gettextParser.mo.parse(data)
            msgstr = trans?.translations?[""]?[str]?.msgstr?[0]
            if msgstr and msgstr isnt str
                return msgstr

        return str



module.exports = GettextWrap

if require.main is module
    gt = new GettextWrap("sv_SE")
    console.log gt.translate("gedit", "Text Editor")



