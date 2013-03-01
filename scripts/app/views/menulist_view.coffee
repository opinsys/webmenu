define [
  "backbone.viewmaster"
  "bacon"

  "cs!app/application"
  "cs!app/utils/navigation"
  "cs!app/views/menuitem_view"
  "hbs!app/templates/menulist"
], (
  ViewMaster
  Bacon

  Application
  Navigation
  MenuItemView
  template
) ->


  class MenuListView extends ViewMaster

    className: "bb-menu-list"

    template: template

    constructor: (opts) ->
      super

      @initial = @model
      @setCurrent()

      @navigation = new Navigation @getMenuItemViews(), @itemCols()

      $(window).keydown (e) =>
        @navigation.cols = @itemCols()
        @navigation.handleKeyEvent(e)

      @$el.css("cursor", "pointer")

      mouseDown = @$el.asEventStream("mousedown")
      mouseUp = $(window).asEventStream("mouseup")
      move = $(document).asEventStream("mousemove")

      active = mouseDown.map(true).merge(mouseUp.map(false)).toProperty(false)

      current = @$el.scrollTop()
      move.merge(@$el.asEventStream("mousedown")).map((e) -> e.pageY).filter(active).diff(0, (a, b) =>
        a - b
      ).onValue (val) =>
        console.log "DIFF #{ val }"
        console.log "CURRENT #{ current }"
        current = current - val
        @$el.scrollTop( current )



      lateActive = move.delay(300).map(active).skipDuplicates().toProperty(false)

      lateActive.onValue (val) ->
        MenuItemView.openDisabled = val
        # console.log "LATE MOVE #{ val }"

      @listenTo this, "reset", =>
        @model = @initial
        @setCurrent()
        @refreshViews()
        @navigation.deactivate()

      @listenTo this, "open-menu", (model) =>
        @model = model
        @setCurrent()
        @refreshViews()

      @listenTo this, "search", (searchString) =>
        if searchString
          @setItems @collection.searchFilter(searchString)
        else
          @setCurrent()
        @refreshViews()
        @navigation.deactivate()

      @listenTo this, "scrollTo", (itemView) =>
        itemBottom = itemView.$el.offset().top + itemView.$el.innerHeight()
        itemTop = itemView.$el.offset().top

        menuListTop = @$el.offset().top
        menuListBottom = @$el.offset().top + @$el.innerHeight()

        if itemBottom > menuListBottom
          @$el.scrollTop( @$el.scrollTop() + itemBottom - menuListBottom )
        else if itemTop < menuListTop
          @$el.scrollTop( @$el.scrollTop() - (menuListTop - itemTop) )

    setCurrent: ->
      @setItems(@model.items.toArray())

    setItems: (models) ->
      @setView ".app-list-container", models.map (model) ->
        new MenuItemView
          model: model
      @$el.scrollTop(0)

    refreshViews: ->
      super
      @navigation.views = @getMenuItemViews()

    itemCols: ->
      parseInt(
        @$el.innerWidth() / @getMenuItemViews()[0].$el.innerWidth()
      )

    getMenuItemViews: ->
      @getViews(".app-list-container")
