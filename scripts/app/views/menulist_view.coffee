define [
  "backbone.viewmaster"

  "cs!app/application"
  "cs!app/utils/navigation"
  "cs!app/views/menuitem_view"
  "hbs!app/templates/menulist"
], (
  ViewMaster

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

      @listenTo this, "reset", =>
        @setItems(@initial.items.toArray())
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

      @listenTo this, "scroll", (itemBottom) =>
        #debugger
        if itemBottom.$el.offset().top - @$el.offset().top + itemBottom.$el.innerHeight() > @$el.innerHeight()
          @$el.scrollTop( @$el.scrollTop() + itemBottom.$el.innerHeight() )
        else if itemBottom.$el.offset().top - @$el.offset().top + itemBottom.$el.innerHeight() < @$el.innerHeight()
          @$el.scrollTop( @$el.scrollTop() - itemBottom.$el.innerHeight() )

        #if itemBottom.$el.innerHeight()
        #@$el.scrollTop( itemBottom + @$el.offset().top - @$el.innerHeight() )
        #@$el.scrollTop( @$el.scrollTop() + itemBottom )

    setCurrent: ->
      @setItems(@model.items.toArray())

    setItems: (models) ->
      @setView ".app-list-container", models.map (model) ->
        new MenuItemView
          model: model

    refreshViews: ->
      super
      @navigation.views = @getMenuItemViews()

    itemCols: ->
      parseInt(
        @$el.innerWidth() / @getMenuItemViews()[0].$el.innerWidth()
      )

    getMenuItemViews: ->
      @getViews(".app-list-container")
