######################################################################
#
# Map case inserted paper images (.svg or .png in Instruments-3d/mapcase/).
# From TU154B
###################################################################################################
#    Antonov-Aircrafts and SpaceShuttle :: Herbert Wagner November2014-May2015
#    Development is ongoing, see latest version: www.github.com/HerbyW
#    This file is licenced under the terms of the GNU General Public Licence V3 or later
#    
#    Reverser, SpaceShuttle, Instrumentation and all Animations for gears, tail-gear-steering, flaps,
#    slats, spoilers, rudder, aelerion and lights for MP-modus with and without Rembrandt added.
####################################################################################################


var mapcase = canvas.new({
    name: "MapCase",
    size: [1024, 1024],
    view: [1024, 988],
    mipmapping: 1,
});
mapcase.addPlacement({ node: "mapcase" });
mapcase.setColorBackground(0.82, 0.82, 0.82, 0);

var root = mapcase.createGroup();

var load_page = func(i) {
    var dir = getprop("sim/aircraft-dir")~"/";
    var filename = "Models/Interior/Panel/Instruments/mapcase/"~page~".svg";
    var svg = 1;
    if (io.stat(dir~filename) == nil) {
       filename = "Models/Interior/Panel/Instruments/mapcase/"~page~".png";
       svg = 0;
       if (io.stat(dir~filename) == nil)
           return nil;
    }
    print("Loading ", filename);
    var g = root.createChild("group", page);
    if (svg)
        canvas.parsesvg(g, filename);
    else
        g.createChild("image").setFile(filename).setSize(1024, 988);
    g.hide();
    return g;
}

print("Map case page loader started");
var page = 1;
while (load_page(page) != nil)
    page += 1;
print("Map case page loader done");

setprop("instrumentation/mapcase/page", 1);

var switch_page = func(i) {
    var pages = size(root.getChildren());
    if (!pages)
        return;
    var page = getprop("instrumentation/mapcase/page");
    root.getElementById(page).hide();
    page += i;
    if (page < 1)
        page = pages;
    else if (page > pages)
        page = 1;
    setprop("instrumentation/mapcase/page", page);
    root.getElementById(page).show();
}
switch_page(0);
