class Bargh

  el: "#container"
  r: null

  home: () ->
    @initEvents()    
    @renderSearch()
    $("#loading").hide()

  renderSearch: ->
    $(@el).html JST['form']()

  searchArtist: (query) ->
    if @r?
      @r.abort()

    @r = $.ajax
      url: 'https://api.spotify.com/v1/search',
      data:
        q: query,
        limit: 20,
        type: "artist"
      
      success: (response) ->
        console.log response.artists
        $("#results").html JST['form_results'](artists: response.artists.items)

  initEvents: ->
    $("body").on "keyup change", "#query", (e) =>
      nop e
      @searchArtist $("#query")[0].value
      return



  # COMPOSER VIEW
  composer: (id) ->
    @renderArtist()
    @fetch(id)
    @results = []
    @albums = []

  renderArtist: ->
    $("#container").html JST['artist']()
    $("#container").on "mouseover", ".inneralbum img", (x) -> 
      x.currentTarget.src = "http://www.clker.com/cliparts/j/W/O/s/N/o/windows-media-player-play-button-md.png"

    $("#container").on "mouseout", ".inneralbum img", (x) -> 
      x.currentTarget.src = ""

    $("#loading").show()

  fetch: (id) ->
    $.ajax
      url: "https://api.spotify.com/v1/artists/#{id}"
      success: (response) =>
        $("#artist_detail").html JST['artist_detail'](artist: response)

    $.ajax
      url: "https://api.spotify.com/v1/artists/#{id}/albums",
      data:
        album_type: "album",
        market: "US"
      success: (response) =>
        @handleAlbums(response)

  handleAlbums: (response) ->
    if response.next?
      @results = @results.concat(_.map(response.items, (x) -> x.id ))
      @fetchNext(response.next)
    else
      console.log("Nope")
      @results = _.uniq @results
      if @results.length == 0
        $("#album_list").html "<h1 style='margin-left: 40px;'>No results found :(</h1>"
      else
        @fetchAlbumData()

  fetchNext: (url) ->
    $.ajax
      url: url

      success: (response) =>
        @handleAlbums(response)    

  fetchAlbumData: ->
    console.log @results
    miau = 0
    for i in [0...@results.length] by 20
      albumIds = @results[i...i+20]

      $.ajax 
        url: "https://api.spotify.com/v1/albums"
        data:
          ids: albumIds.join(",")

        success: (response) =>
          console.log response.albums
          @albums = @albums.concat response.albums
          
          miau+=20

          if miau >= @results.length
            console.log "CLA"
            @calculatez()

  calculatez: ->
    for album in @albums
      album.stats = {}

      album.stats.artist_count = 1 - album.artists.length / 10
      album.stats.popularity = album.popularity / 10.0

      # Calculate age
      jetzt = moment().unix()
      albumdate = moment(album.release_date).unix()

      album.stats.age = 2 * (jetzt - albumdate) / jetzt

      album_artists = []
      # get number of artists on tracks
      for track in album.tracks.items
        album_artists = album_artists.concat track.artists

      album.stats.track_artist_count = 1 - _.uniq(album_artists, (x) -> x.id).length / 10
    
      album.stats.sum = album.stats.artist_count + album.stats.age + album.stats.track_artist_count

    @albums = _.sortBy @albums, (x) -> -x.stats.sum

    @renderAlbums()

  renderAlbums: ->
    $("#loading").hide()
    $("#album_list").html JST['artist_works'](albums: @albums)
