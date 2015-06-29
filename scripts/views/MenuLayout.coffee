
Backbone = require "backbone"
ViewMaster = require "../vendor/backbone.viewmaster"

Application = require "../Application.coffee"
Favorites = require "./Favorites.coffee"
Lightbox = require "./Lightbox.coffee"
MenuItemConfirmView = require "./MenuItemConfirmView.coffee"
Breadcrumbs = require "./Breadcrumbs.coffee"
MenuListView = require "./MenuListView.coffee"
SidebarView = require "./SidebarView.coffee"
Search = require "./Search.coffee"

class HostnameView extends ViewMaster
    template: (context) ->
        "<div class=machine-hostname>#{context.hostname}</div>"


class MenuLayout extends ViewMaster

    className: "bb-menu-layout"

    template: require "../templates/MenuLayout.hbs"

    constructor: (opts) ->
        super

        @allItems = opts.allItems
        @user = opts.user
        @config = opts.config
        @lightbox = null

        @menuListView = new MenuListView
            model: opts.initialMenu
            collection: opts.allItems
            config: opts.config

        @setView ".menu-list-container", @menuListView

        @search = new Search
        @hostnameView = new HostnameView model: @config
        @setView ".search-container", @search

        @breadcrumbs = new Breadcrumbs model: opts.initialMenu
        @setView ".breadcrumbs-container", @breadcrumbs

        @sidebarView = new SidebarView(opts)
        @setView ".sidebar-container", @sidebarView

        @favorites =  new Favorites
            collection: @allItems
            config: @config
        @setView ".favorites-container", @favorites

        @listenTo this, "open-menu", (model, sender) =>
            # Update MenuListView when user navigates from breadcrumbs
            if sender is @breadcrumbs
                @menuListView.broadcast("open-menu", model)
            # Update breadcrums when user navigates from menu tree
            if sender isnt @breadcrumbs
                @breadcrumbs.broadcast("open-menu", model)

        @listenTo this, "open-confirm", (model) =>
            @displayViewInLightbox new MenuItemConfirmView
                model: model
                config: @config

        # Lightbox is not the same DOM tree as the other views. So manually
        # proxy all message to it too
        @listenTo this, "all", (eventName, arg) =>
            if @lightbox
                @lightbox.broadcast(eventName, arg)


        # Connect search events to MenuListView
        @listenTo this, "search", (searchString) =>
            @menuListView.broadcast("search", searchString)


        @listenTo this, "open-root-view", =>
            @setView ".favorites-container", @favorites
            @hostnameView.detach()
            @setView ".search-container", @search
            @setView ".breadcrumbs-container", @breadcrumbs
            @removeLightbox()
            @refreshViews()

        @listenTo this, "open-logout-view", =>
            @favorites.detach()
            @search.detach()
            @setView ".search-container", @hostnameView
            @breadcrumbs.detach()
            @menuListView.broadcast("open-logout-view")
            @$(".favorites-container").empty()
            @$(".breadcrumbs-container").empty()
            @refreshViews()


    displayViewInLightbox: (view) ->
        @menuListView.releaseKeys()
        @removeLightbox()
        @lightbox = new Lightbox
            view: view
            position: "fullscreen"
        @lightbox.parent = this
        @lightbox.render()
        @lightbox.once "close", =>
            @removeLightbox()

    removeLightbox: ->
        if @lightbox
            @menuListView.grabKeys()
            @lightbox.remove()
            @lightbox = null

module.exports = MenuLayout

