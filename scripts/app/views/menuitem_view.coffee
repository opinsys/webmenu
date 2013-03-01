define [
  "underscore"
  "app/views/spin"
  "backbone.viewmaster"

  "hbs!app/templates/menuitem"
  "app/utils/debounce"
  "cs!app/utils/render_fix"
  "cs!app/application"
], (
  _
  spin
  ViewMaster

  template
  debounce
  renderFix
  Application
) ->

  class MenuItemView extends ViewMaster

    MenuItemView.openDisabled = false

    className: "bb-menu-item"

    template: template

    constructor: ->
      super

      # Make sure that single app can be opened only once in 250ms. Prevents
      # situations when holding down enter key might spawn multiple instances
      # of the same app
      @open = _.throttle(@open, 250)

      @$el.addClass "item-" + @model.get("name")
        .toLowerCase()
        .replace(/[^a-z]/g, "")

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
      "mouseup": "open"
      "mouseover": "toggleInactiveNotify"
      "mouseout": "toggleInactiveNotify"

    elements:
      "$thumbnail": ".thumbnail"
      "$description": ".description"
      "$img": "img,.cssIcon"

    open: ->
      return if MenuItemView.openDisabled
      return if @isInactive()

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
