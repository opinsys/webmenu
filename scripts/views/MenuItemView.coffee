_ = require "underscore"

ViewMaster = require "../vendor/backbone.viewmaster"
renderFix = require "../utils/renderFix.coffee"

class MenuItemView extends ViewMaster

    className: "bb-menu-item"

    template: require "../templates/MenuItemView.hbs"

    constructor: ->
        super

        # Make sure that single app can be opened only once in 250ms. Prevents
        # situations when holding down enter key might spawn multiple instances
        # of the same app
        @open = _.throttle(@open, 250)

        if id = @model.get("id")
            @$el.addClass("item-#{ id }")

        if @model.get("type") is "menu"
            @$el.addClass("type-menu")
        else
            # Normalize "desktop", "custom" to "app"
            @$el.addClass("type-app")

        if @isInactive()
            @$el.addClass "inactive"

        @listenTo this, "hide-window", =>
            @$img.removeClass("rotate-loading")

    events:
        "click": "open"
        "mouseover": "toggleInactiveNotify"
        "mouseout": "toggleInactiveNotify"

    elements:
        "$thumbnail": ".thumbnail"
        "$description": ".description"
        "$img": "img,.cssIcon"

    open: ->

        if @isInactive()
            return

        if @model.get("type") is "menu"
            renderFix()
            @bubble "open-menu", @model
        else
            @bubble "open-app", @model
            @model.incClicks()
            @$img.addClass("rotate-loading")

    toggleInactiveNotify: ->
        if @isInactive()
            @$('.inactiveNotify').toggle()

    context: ->
        json = super()
        json.menu = @model.get("type") is "menu"
        return json

    displaySelectHighlight: ->
        @$el.addClass "selectHighlight"

    hideSelectHighlight: ->
        @$el.removeClass "selectHighlight"

    scrollTo: ->
        @bubble "scrollTo", @

    isInactive: ->
        @model.get("status") is "inactive"

module.exports = MenuItemView