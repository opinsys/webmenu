
ViewMaster = require "../vendor/backbone.viewmaster"
_ = require "underscore"



class Tabs extends ViewMaster

    className: ".bb-tabs"

    template: require "../templates/Tabs.hbs"

    events:
        "click a": "selectTab"

    selectTab: (e) ->
        debugger

    context: ->
        return {
            tabs: @collection.map (coll, index) ->
                _.extend(coll.toJSON(), {index: index})
        }




module.exports = Tabs
