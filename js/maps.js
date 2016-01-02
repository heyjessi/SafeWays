var listCoord = [];
var lines = []; // keeps tracks of lines drawn on map

function buildRoutes(json) {
  listCoord = [];
  var routes = json["routes"];
  for(var j = 0; j<routes.length; j++){
    listCoord[j] = [];
    var steps = json["routes"][j]["legs"][0]["steps"]
    for ( var i = 0; i < steps.length; i++) {
      var line = steps[i]["polyline"]["points"];
      listCoord[j].push.apply(listCoord[j], google.maps.geometry.encoding.decodePath(line));
    } 
  }
}

// buildRoutes(json);

var map;

function resetLines() {
  for(var k = 0; k < lines.length; k++) {
    lines[k].setMap(null);
  }
  lines = [];
}

function initialize() {
  var mapOptions = {
    center:  new google.maps.LatLng(37.7833, -122.4167), // this also works{ lat: 37.7833, lng: -122.4167},
    zoom: 12
  };

  redrawMap(mapOptions);
}

function redrawMap(mapOptions) {
  resetLines();

  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);

  var colorArray = ['green', 'yellow', 'red'];
  var boldness = [6, 4, 2];
  var infoBox = [
    {
      position: 0,
      safetyScore: 912,
      info: "2.3 miles: 52 min"
    },
    {
      position: 30,
      safetyScore: 883,
      info: "2.0 miles: 40 min"
    },
    {
      position: 60,
      safetyScore: 514,
      info: "1.3 miles: 25 min",
    }
  ]; // TODO: HACK

  for(var k = 0; k < listCoord.length; k++) {
    var flightPath = new google.maps.Polyline({
      path: listCoord[k],
      geodesic: true,
      strokeColor: colorArray[k], 
      strokeOpacity: 1.0,
      strokeWeight: boldness[k] 
    });
    flightPath.setMap(map);
    lines.push(flightPath);

    // adding infobox stuff below.  comment out if not needed
    info = infoBox[k];
    var infowindow = new google.maps.InfoWindow({
             content: info["info"]});
    infowindow.setPosition(flightPath.getPath().getArray()[info["position"]]);
    infowindow.open(map);
  }
}

google.maps.event.addDomListener(window, 'load', initialize);

google.maps.event.addDomListener(window, "resize", function() {
  var center = map.getCenter();
  google.maps.event.trigger(map, "resize");
  map.setCenter(center); 
});

// initialize after jquery load & page load
$(document).ready(function() {
  $('#submit').click(function(){
      var queryString = $('form').serialize();
      $.ajax({
        url: "http://chime.notifsta.com/directions?" + queryString,
        method: "GET",
        success: function(data) {
          console.log("success");
          console.log(data);
          buildRoutes(data);
          initialize();
        },
        error: function(data) {
          console.log("should not error");
          console.log(data);
        }
      });
    event.preventDefault();
  });
});