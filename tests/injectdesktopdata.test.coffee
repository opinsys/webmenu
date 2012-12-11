
{expect} = require "chai"
menutools = require "../lib/menutools"

dir = __dirname + "/dotdesktop"
iconsDir = __dirname + "/icons"
fallbackIconPath = iconsDir + "/fallbackIcon.png"

describe "inject dot desktop data", ->
  describe "single item", ->

    menu = null
    beforeEach ->
      menu =
        type: "desktop"
        id: "thunderbird"
      menutools.injectDesktopData(menu, [dir], "fi_FI.UTF-8", [iconsDir], fallbackIconPath)

    it "gets description", -> expect(menu.description).to.be.ok
    it "gets name", -> expect(menu.name).to.be.ok
    it "gets command", -> expect(menu.command).to.be.ok
    it "gets upstreamName", -> expect(menu.upstreamName).to.be.ok
    it "gets icon", -> expect(menu.osIconPath).to.eq iconsDir + "/thunderbird.png"


  describe "menu.json can force attributes", ->

    menu = null
    beforeEach ->
      menu =
        type: "desktop"
        id: "thunderbird"
        name: "forced name"
      menutools.injectDesktopData(menu, [dir], "fi_FI.UTF-8", [iconsDir], fallbackIconPath)

    it "should have forced name", ->
      expect(menu.name).to.eq "forced name"

  describe "Use default icon if application's icon not found", ->

    menu = null
    beforeEach ->
      menu =
        type: "desktop"
        id: "gedit"
      menutools.injectDesktopData(menu, [dir], "fi_FI.UTF-8", [iconsDir], fallbackIconPath)

    it "should have default icon", ->
      expect(menu.osIconPath).to.eq fallbackIconPath
