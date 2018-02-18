
$fn=90;
//clip pcb mount
module clipMount(pos, outerDia, innerDia, height, pcbThickness) {
    translate([pos[0],pos[1],0])
    {
        difference(){
            union(){
                cylinder(h = height, d1 = outerDia, d2 = outerDia, center = false);
                translate([0,0,height]){cylinder(h = pcbThickness, d1 = innerDia, d2 = innerDia, center = false);}
                translate([0,0,height+pcbThickness]){cylinder(h = 1, d1 = innerDia, d2 = 1.4*innerDia, center = false);}
                translate([0,0,height+pcbThickness+1]){cylinder(h = 2, d1 = 1.4*innerDia, d2 = 0.8*innerDia, center = false);}
            }
            translate([-1/6*innerDia,-outerDia,height+1/3*pcbThickness]){cube([1/3*innerDia,2*outerDia,3+pcbThickness],center=false);}
        }
    }
}

clipMount([50,10], 5, 3, 4, 1.6);
clipMount([10,50], 5, 3, 4, 1.6);
clipMount([50,50], 5, 3, 4, 1.6);
clipMount([10,10], 5, 3, 4, 1.6);