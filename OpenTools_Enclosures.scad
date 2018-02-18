// OpenTools_Enclosures.scad
// OpenSCAD library for sensor / PCB enclosures
// (C) 2018, Theo Meyer, AloyseTech
// (C) 2017, Reinhold Kainhofer, Open Tools
// office@open-tools.net, https://www.open-tools.net/
// License: This work is licensed under a Creative Commons Attribution 4.0 International License.
//
// Features:
// * roundedbox(dim, r): Rounded boxes
// * pcbbox(dim, r, innerr, w, top, ridge): Rounded PCB enclosure, with bottom and top part (height given by top)
// * pcbmount(type, pos, dia, len, innerdia, holedia, pcbthick, screwdia): PCB mount (type="screw"/"clip"/
// * pcbscrew(pos, dia, innerdia, len): Screw mount inside the box to screw a PCB to the enclosure
// * pcbstackon(pos, dia, len, holedia, pcbthick): Stack-on mount inside the screw to hold a PCB
// * boxscrew(pos, dia, innerdia, screwdia, len): Screw holder to screw the top and bottom parts of the enclosure together
// * boxcutout(...): Cut out parts of the box

///////////////////////////////
//  ENCLOSURE CONFIGURATION  //
///////////////////////////////

//pcb settings
pcb_width       = 35;
pcb_length      = 60;
pcb_thickness   = 1.6;

//enclosure settings
box_wallThickness               = 3;
box_innerHeight                 = 35;
box_pcbHeightFromBottom         = pcb_thickness + 1.4;
box_pcbDistFromWall				= 0.5;
box_splitHeightFromPcbTop       = 8;   //distance Z from top of the pcb to enclosure top/bottom separation plan
//box_splitHeightFromPcbTop       = box_innerHeight/2 - box_pcbHeightFromBottom;   //distance Z from top of the pcb to enclosure top/bottom separation plan


//PCB mount CONFIGURATION
mounts = [
			[20, 20, 5, 2, "stack"],
			[5, 5, 5, 2, "stack"],
			[10, 10, 5, 2, "clip"],
			[20, 30, 5, 2, "clip"]
		];



///////////////////////////////
//   END OF CONFIGURATION    //
///////////////////////////////

//internal settings
$fn=50;

// assertions
if(box_pcbHeightFromBottom < pcb_thickness)
{
    error("box_pcbHeightFromBottom must be >= pcb_thickness !");
}


module error(string)
{
    echo(str("<font color='red'>","ERROR : ", string,"</font>"));
};

module assert(a, b, cmp = "==", msg = "ERROR! Bad parameters")
{
    if(cmp == "==")
    {
            if(!(a == b))
                error(msg);
    }
    else if (cmp =="<")
    {
    }
        //...
}


module roundedbox(dim, r=2) {
  minkowski() { // rounded corners
    translate([r,r,r]) cube(dim-[2*r, 2*r, 2*r]);
      //cube(dim);
    sphere(r);
  };
}


module pcbbox(dim, outerRadius=2, innerRadius=1, wallThickness=2, pcbWallClearance = 0.5, splitHeight=10, ridge=4, ridgeratio=1/2) {
  offset = [0, dim[1]+10, 0];
  innerHeight = dim[2];
  topInnerHeight = innerHeight - (box_pcbHeightFromBottom + splitHeight);
  bottomInnerHeight = box_pcbHeightFromBottom + splitHeight;
  outerDim = dim + [wallThickness + pcbWallClearance, wallThickness + pcbWallClearance, 0];
  innerDim = outerDim - 2 * wallThickness*[1,1,1];
  // Bottom part
  difference() { // Cut out interior
    union() {
      difference() {
        roundedbox(outerDim, outerRadius);
        translate([-1,-1,wallThickness + bottomInnerHeight]) cube(outerDim+[2,2,0]); // Cut off top
      };
      
      difference() {
        translate((1-ridgeratio)*[wallThickness, wallThickness, wallThickness]) roundedbox(outerDim - 2*(1-ridgeratio)*(wallThickness*[1,1,1]), ridgeratio*outerRadius);
        translate([-1,-1, wallThickness + bottomInnerHeight + ridge ]) cube(outerDim+[2,2,0]); // Cut off top of ridge
      }
    };
    translate([wallThickness, wallThickness, wallThickness]) roundedbox(innerDim +[0,0,wallThickness], innerRadius); // Cut out interior
  }
  
  //top part
  difference() { // Cut off top
    translate(offset) {
      difference() {
        roundedbox(outerDim, outerRadius);
        translate([-1,-1,wallThickness + topInnerHeight]) cube(outerDim+[2,2,0]);
      }
    };

    difference() {
      translate(offset + (1-ridgeratio)*[wallThickness, wallThickness, wallThickness]) roundedbox(outerDim-2*(1-ridgeratio)*wallThickness*[1,1,1], ridgeratio*outerRadius);
      //translate(offset + [-1,-1,-outerDim[2]+topInnerHeight-ridge]) cube(outerDim+[2,2,0]); // Cut off topInnerHeight of ridge
      translate(offset + [-1,-1,-outerDim[2]+wallThickness+topInnerHeight-ridge]) cube(outerDim+[2,2,0]); // Cut off topInnerHeight of ridge
    };
    translate(offset + [wallThickness, wallThickness, wallThickness]) roundedbox(innerDim, innerRadius); // Cut out interior
  }
}

module pcbmount(type="screw", pos, dia=2, innerdia=1, len=10, w=2, pcbthick=2) {
  translate([pos[0], pos[1], w]) difference() {
    if (type=="screw") {
      difference() {
        cylinder(h=len, d=dia);
        cylinder(h=len+0.01, d=innerdia);
      }
    } else if (type=="clip") {
        difference()
        {
            union()
            {
                cylinder(h = len, d1 = dia, d2 = dia, center = false);
                translate([0,0,len]){cylinder(h = pcbthick, d1 = innerdia, d2 = innerdia, center = false);}
                translate([0,0,len+pcbthick]){cylinder(h = 1, d1 = innerdia, d2 = 1.4*innerdia, center = false);}
                translate([0,0,len+pcbthick+1]){cylinder(h = 2, d1 = 1.4*innerdia, d2 = 0.8*innerdia, center = false);}
            }
            translate([-1/6*innerdia,-dia,len+1/3*pcbthick]){cube([1/3*innerdia,2*dia,3+pcbthick],center=false);}
        }
    } else if (type=="stack") {
      cylinder(h=len, d=dia);
      cylinder(h=len+pcbthick, d=innerdia);
    } else {
      echo ("Unknown pcbmount ", type=type, " ignoring call.");
    }
  }
}

//module pcbspacer(axis="x", pos, l, l1, l2, h, h1, h2, w=0.5) {
module pcbspacer(axis="x", pos, l, h, w=0.5, boxw=2, dim) {
  if (axis=="x") {
    if (l>0) {
      translate([pos-w/2, boxw, boxw]) cube([w, l, h]);
    } else {
      translate([pos-w/2, dim[1]-boxw+l, boxw]) cube([w, -l, h]);
    }
  } else if (axis=="y") {
    if (l>0) {
      translate([boxw, pos-w/2, boxw]) cube([l, w, h]);
    } else {
      translate([dim[0]-boxw+l, pos-w/2, boxw]) cube([-l, w, h]);
    }
  } else if (axis=="z") {
    echo ("pcbspacer with axis=z not yet implemented...");
  } else {
      echo ("Unknown pcbspacer axis ", axis, " ignoring call.");
  }
}

module pcbspacersym(axis="x", pos, l, h, w=0.5, boxw=2, dim) {
  union() {
    pcbspacer(axis, pos, l, h, w, boxw, dim);
    pcbspacer(axis, pos, -l, h, w, boxw, dim);
  }
}  
module pcbspacerl(axis="x", pos, l1, l2, h1, h2, w=0.5, boxw=2, dim) {
  union() {
    pcbspacer(axis, pos, l1, h2, w, boxw, dim);
    pcbspacer(axis, pos, l2, h1, w, boxw, dim);
  }
}  
module pcbspacerlsym(axis="x", pos, l1, l2, h1, h2, w=0.5, boxw=2, dim) {
  union() {
    pcbspacer(axis, pos, l1, h2, w, boxw, dim);
    pcbspacer(axis, pos, l2, h1, w, boxw, dim);
    pcbspacer(axis, pos, -l1, h2, w, boxw, dim);
    pcbspacer(axis, pos, -l2, h1, w, boxw, dim);
  }
}

module clipMount(pos, outerDia, innerDia, height, pcbThickness) {
    translate([pos[0],pos[1],0])
    {
        difference()
        {
            union()
            {
                cylinder(h = height, d1 = outerDia, d2 = outerDia, center = false);
                translate([0,0,height]){cylinder(h = pcbThickness, d1 = innerDia, d2 = innerDia, center = false);}
                translate([0,0,height+pcbThickness]){cylinder(h = 1, d1 = innerDia, d2 = 1.4*innerDia, center = false);}
                translate([0,0,height+pcbThickness+1]){cylinder(h = 2, d1 = 1.4*innerDia, d2 = 0.8*innerDia, center = false);}
            }
            translate([-1/6*innerDia,-outerDia,height+1/3*pcbThickness]){cube([1/3*innerDia,2*outerDia,3+pcbThickness],center=false);}
        }
    }
}


difference() {
  union() {
//      roundedbox([10,10,10]);
    pcbbox(dim=[pcb_length,pcb_width,box_innerHeight], 
            outerRadius = 2, innerRadius=1,
            wallThickness = box_wallThickness,
            splitHeight = box_splitHeightFromPcbTop);

    for(m = mounts)
    {
    	pcbmount(pos = [m[0], m[1]], dia = m[2], innerdia = m[3], type = m[4], len = box_pcbHeightFromBottom - pcb_thickness, w = box_wallThickness);
    }
    pcbmount(pos=[0, 0], dia=6 , innerdia=2, len=15, w = box_wallThickness);
    pcbmount(pos=[0, 60], dia=6 , innerdia=2, len=15, w = box_wallThickness);
//    pcbmount(pos=[40, 20], dia=5, innerdia=2, len=3, w=2);
//    pcbmount(type="stack", pos=[10, 10], dia=5, innerdia=3, len=3, w=2);
//    pcbmount(pos=[20, 20], dia=3, innerdia=1, len=5, w=2);
//    pcbmount(type="stack", pos=[30, 20], dia=3, innerdia=1, len=5, w=2, pcbthick=2);
//    pcbmount(type="something", pos=[30, 20], dia=3, innerdia=1, len=5, w=2, pcbthick=2);
//    pcbspacer(axis="x", pos=15, l=3, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="x", pos=15, l=1, h=5, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="x", pos=15, l=-2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="x", pos=35, l=2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="y", pos=5, l=2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacer(axis="y", pos=5, l=-2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
//    pcbspacersym(axis="y", pos=25, l=2, h=3, w=0.5, boxw=2, dim=[50,30,30]);
  };
  
};