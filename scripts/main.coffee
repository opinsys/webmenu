$ = require "./vendor/jquery.shim"
Backbone = require "backbone"
Q = require "q"

Application = require "./Application.coffee"
MenuLayout = require "./views/MenuLayout.coffee"
AllItems = require "./models/AllItems.coffee"
MenuModel = require "./models/MenuModel.coffee"

nodejs = window.nodejs

{user, config, menu} = nodejs

user = new Backbone.Model user
config = new Backbone.Model config
allItems = new AllItems
menuModel = new MenuModel menu, allItems

layout = new MenuLayout
    user: user
    config: config
    initialMenu: menuModel
    allItems: allItems


# Convert selected menu item models to CMD Events
# https://github.com/opinsys/webmenu/blob/master/docs/menujson.md
hideTimer = null
layout.on "open-app", (model) ->
    # This will be send to node and node-webkit handlers
    nodejs.open(model.toTranslatedJSON())

    # Hide window after animation as played for few seconds or when the
    # opening app steals focus
    hideTimer = setTimeout ->
        nodejs.hideWindow()
    , Application.animationDuration

# Disable DOM element dragging and text selection if target is not an input
$(window).on "mousedown", (e) ->
    if e.target.tagName not in ["INPUT", "SELECT", "OPTION", "TEXTAREA"]
        e.preventDefault()

$(window).keydown (e) ->
    if e.which is 27 # Esc
        nodejs.hideWindow()

# Hide window when focus is lost
$(window).blur ->
    # Clear hideTimer on blur to avoid unwanted hiding if user immediately
    # spawns menu again
    clearTimeout(hideTimer)
    nodejs.hideWindow()
    layout.broadcast("hide-window")

layout.render()
$ -> $("body").html layout.el

nodejs.on "open-view", (viewName) ->
    layout.broadcast("reset")
    if viewName
        layout.broadcast("open-#{ viewName }-view")

layout.on "send-feedback", (feedback) ->
    nodejs.sendFeedback(feedback.toJSON())
    .fail (err) ->
        console.log "failed to send feedback #{ err.message }"

layout.on "logout-action", (action, feedback) ->
    (
        if feedback.haveFeedback()
            nodejs.sendFeedback(feedback.toJSON())
        else
            Q()
    ).fail (err) ->
        console.error "Failed to send feedback #{ err.message }"
    .finally (foo) ->
        console.log "finally #{ foo }"
        nodejs.hideWindow()
        nodejs[action]()

nodejs.logReady()
