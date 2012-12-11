define [
  "cs!app/models/menu_model"
  "cs!app/models/allitems_collection"
  "backbone"
],
(
  MenuModel
  AllItems
  Backbone
)->

  data =
    type: "menu"
    name: "Top"
    items: [
      type: "desktop"
      name: "Gimp"
      command: ["gimp"]
    ,
      type: "desktop"
      name: "Shotwell"
      command: ["shotwell"]
    ,
      type: "web"
      name: "Flickr"
      url: "http://flickr.com"
    ,
      type: "web"
      name: "Picasa"
      url: "http://picasa.com"
    ]

  describe "AllItems Collection", ->

    allItems = null
    beforeEach ->
      allItems = new AllItems
      new MenuModel data, allItems

      allItems.find((m) ->
        m.get("name") is "Gimp"
      ).set("clicks", 5)

      allItems.find((m) ->
        m.get("name") is "Shotwell"
      ).set("clicks", 10)

      allItems.find((m) ->
        m.get("name") is "Flickr"
      ).set("clicks", 15)

    it "can list most popular apps", ->
      favorites = allItems.favorites().map (m) -> m.get("name")
      expect(favorites).to.deep.eq ["Flickr", "Shotwell", "Gimp"]

    it "can limit the list of favorites", ->
      expect(allItems.favorites(1).length).to.eq 1
      expect(allItems.favorites(2).length).to.eq 2
      expect(allItems.favorites(10).length).to.eq 3


    describe "searchFilter()", ->
      itemData = [
        type: "custom"
        name: "good"
        command: "good-cmd"
        description: "foo bar descriptiontest"
      ,
        type: "custom"
        name: "bad"
        command: "bad-cmd"
      ]

      it "it filters item by name attribute", ->
        itemsColl = new AllItems itemData
        filtered = itemsColl.searchFilter("good")

        expect(
          _.find filtered, (model) -> model.get("name") is "good"
          "good item should be included"
        ).to.be.ok

        expect(
          _.find(filtered, (model) -> model.get("name") is "bad"),
          "bad item should not be included"
        ).to.be.not.ok


      it "it filters item by description attribute", ->
        itemsColl = new AllItems itemData
        filtered = itemsColl.searchFilter("descriptiontest")

        expect(
          _.find filtered, (model) -> model.get("name") is "good"
          "good item should be included"
        ).to.be.ok

        expect(
          _.find(filtered, (model) -> model.get("name") is "bad"),
          "bad item should not be included"
        ).to.be.not.ok


