resolution = 32;

inch = 25.4; // be able to stick with metric, but have it be meaningful

left   = -1;
right  = 1;
front  = -1;
rear   = 1;
top    = 1;
bottom = -1;

// access coordinates in a meaningful way
x = 0;
y = 1;
z = 2;

m5_bolt_diam        = 5.25;
m5_bolt_head_height = 5;
m5_bolt_head_diam   = 9;
m5_nut_thickness    = 5;
m3_bolt_diam        = 3.25;
m3_bolt_head_height = 5;
m3_bolt_head_diam   = 6;

m2_threaded_insert_diam = 3.4;
m2_5_threaded_insert_diam = 3.6;
m3_threaded_insert_diam = 5.4;
m2_5_loose_hole = 2.5 + 0.3;
m3_loose_hole = 3.4;
m5_tight_hole = 5;
m5_loose_hole = 5.2;
m5_thread_into_plastic_hole_diam = 4.65;
m4_thread_into_plastic_hole_diam = 3.7;
m3_thread_into_plastic_hole_diam = 2.8;
m2_5_thread_into_plastic_hole_diam = 2.5-0.2;
m2_thread_into_plastic_hole_diam = 2-0.2;

mini_v_wheel_od = 15.23;
mini_v_wheel_smaller_od = 12.21; // according to some random image of the internet
mini_v_wheel_id = 10;
mini_v_wheel_thickness = 8.8;
mini_v_wheel_flat_width = 5.78;
mini_v_wheel_extrusion_spacing = 11.90/2; // distance from edge of aluminum extrusion to wheel axle
mini_v_wheel_plate_thickness = 8;
mini_v_wheel_plate_above_extrusion = -10 + mini_v_wheel_thickness/2 + 1 + 6;
// mini_v_wheel_belt_above_extrusion = -v_slot_cavity_depth+10+6/2+1.3; // 8.2
mini_v_wheel_belt_above_extrusion = 8.2;

m3_diam = 3;
m3_socket_head_height = 3.25;
m3_socket_head_diam = 5.6;
m3_nut_diam = 5.5;
m3_fsc_head_diam = 6;

m4_diam = 4;
//m4_socket_head_height = 4;
//m4_socket_head_diam = 7.25;
//m4_nut_diam = 8;
m4_fsc_head_diam = 8;

m5_diam = 5;
m5_socket_head_height = 6;
m5_socket_head_diam = 9;
m5_nut_diam = 8;
m5_fsc_head_diam = 10;

m6_diam = 6;
m6_socket_head_height = 7;
m6_nut_diam = 0;
m6_fsc_head_diam = 12;

countersink_default_length = 30;

byj_body_diam = 28;
byj_height = 19.5; // body is 19, but flanges stick up

byj_shaft_diam = 5.2;
byj_flange_width = 42;
byj_flange_diam = 7;
byj_flange_thickness = 0.8;
byj_flange_hole_diam = 4.2;
byj_hole_spacing = 35;

byj_shaft_from_center = 8;
byj_shaft_len = 7.9; // varies between 7.9 and 8.5, due to slop in the shaft
byj_shaft_flat_len = 6.1;
byj_shaft_flat_thickness = 3;
byj_shaft_flat_offset = 0;
byj_shaft_flat_cut_depth = (byj_shaft_diam-byj_shaft_flat_thickness)/2;
byj_shoulder_diam = 9.25;
byj_shoulder_height = 1.7; // what drawings say.  Actual measurement is 1.6

byj_hump_height = 16.8;
byj_hump_width = 15;
byj_hump_depth = 17-byj_body_diam/2;

function accurate_diam(diam,sides) = 1 / cos(180/sides) / 2 * diam;

module hole(diam,len,sides=8) {
  rotate([0,0,180/sides]) {
    cylinder(r=accurate_diam(diam,sides),h=len,center=true,$fn=sides);
  }
}

module accurate_circle(diam,sides=8) {
  rotate([0,0,180/sides]) {
    circle(r=accurate_diam(diam,sides),$fn=sides);
  }
}

module debug_axes(sides=0.1, opacity=0.5) {
  % union() {
    color("red", opacity) translate([50,0,0]) cube([100,sides,sides],center=true);
    color("green", opacity) translate([0,50,0]) cube([sides,100,sides],center=true);
    color("blue", opacity) translate([0,0,50]) cube([sides,sides,100],center=true);
  }
}

module ring(id,thickness,height,fn=16) {
  od = id + thickness;
  linear_extrude(height=height,center=true) {
    difference() {
      accurate_circle(od,fn);
      accurate_circle(id,fn);
    }
  }
}

module rounded_square(width,depth,diam,fn=resolution) {
  pos_x = width/2-diam/2;
  pos_y = depth/2-diam/2;

  hull() {
    for(x=[left,right]) {
      for(y=[front,rear]) {
        translate([x*pos_x,y*pos_y,0]) {
          accurate_circle(diam,fn);
        }
      }
    }
  }
}

module rounded_cube(width,depth,height,diam,fn=resolution) {
  linear_extrude(height=height,center=true,convexity=3) {
    rounded_square(width,depth,diam,fn);
  }
}

module round_corner_filler(diam,length) {
  linear_extrude(height=length,center=true,convexity=3) {
    round_corner_filler_profile(diam);
  }
}

module round_corner_filler_profile(diam,res=resolution) {
  extra = 0.1;
  main = diam/2+extra;
  difference() {
    translate([diam/4-extra,diam/4-extra,0]) {
      square([main,main],center=true);
    }
    translate([diam/2,diam/2,0]) {
      accurate_circle(diam,res);
    }
  }
}

module space_along_length(length,min_hole_spacing=4*inch,from_end=1*inch) {
  avail_length = length - (from_end*2);
  num_spaces   = floor(avail_length / min_hole_spacing);
  extra_space  = (avail_length - (num_spaces*min_hole_spacing)) / num_spaces;
  spacing      = min_hole_spacing + extra_space;

  // echo(length, num_spaces, spacing);

  translate([0,-length/2+from_end,0]) {
    for(y=[0:num_spaces]) {
      translate([0,y*spacing,0]) {
        children();
      }
    }
  }
}

module letter_spike(thin_width,thick_width,thickness) {
  hull() {
    cylinder(r=thin_width,h=thickness*2,center=true,$fn=16);
    cylinder(r=thick_width,h=0.01,center=true,$fn=16);
  }
}

module letter_L(width=10,height=20,thickness=0.5,thick_width=2,thin_width=0.3) {
  lines = [
    [
      [-width/2,height/2,0],
      [-width/2,-height/2,0],
    ],
    [
      [-width/2,-height/2,0],
      [width/2,-height/2,0],
    ],
  ];

  for(pair=lines) {
    hull() {
      for(vect=pair) {
        translate(vect) {
          letter_spike(thin_width,thick_width,thickness);
        }
      }
    }
  }
}

module letter_R(width=10,height=20,thickness=0.5,thick_width=2,thin_width=0.3) {
  lines = [
    [
      [-width/2,height/2,0],
      [-width/2,-height/2,0],
    ],
    [
      [-width/2,height/2,0],
      [width/2,height/3,0],
    ],
    [
      [width/2,height/3,0],
      [-width/4,0,0],
    ],
    [
      [-width/2,0,0],
      [-width/4,0,0],
    ],
    [
      [-width/4,0,0],
      [width/2,-height/2,0],
    ],
  ];

  for(pair=lines) {
    hull() {
      for(vect=pair) {
        translate(vect) {
          letter_spike(thin_width,thick_width,thickness);
        }
      }
    }
  }
}

module zip_tie_cavity(inner_diam_input,zip_tie_thickness,zip_tie_width,fn=resolution) {
  inner_diam = inner_diam_input -0.05;
  overall_width = inner_diam+zip_tie_thickness*2;

  module profile() {
    for(x=[left,right]) {
      translate([x*(inner_diam/2+zip_tie_thickness/2),overall_width,0]) {
        square([zip_tie_thickness,overall_width*2],center=true);
      }
    }

    intersection() {
      translate([0,-overall_width,0]) {
        square([overall_width*2,overall_width*2],center=true);
      }
      difference() {
        accurate_circle(inner_diam+zip_tie_thickness*2,fn);
        accurate_circle(inner_diam,fn);
      }
    }
  }

  linear_extrude(height=zip_tie_width,convexity=3,center=true) {
    profile();
  }
}

module printed_extrusion_carriage_profile(body_width,body_height) {
  spring_thickness = extrude_width*4;
  spring_gap_width = 1;
  preload = -0.2; // negative makes more slack both for print and UHMWPE tape
  wall_thickness = extrude_width*4;

  cavity_width = body_width - wall_thickness*4;
  cavity_height = body_height - wall_thickness*4;

  module spring_profile() {
    contact_width = 8;

    translate([0,-preload+spring_thickness/2]) {
      translate([left*(y_rail_extrusion_width/2-contact_width/2),0,0]) {
        rounded_square(contact_width,spring_thickness,spring_thickness);
      }
      hull() {
        translate([left*(y_rail_extrusion_width/2-contact_width+spring_thickness/2),0,0]) {
          accurate_circle(spring_thickness,resolution);
        }
        translate([right*(y_rail_extrusion_width/2-spring_thickness),spring_gap_width/2,0]) {
          accurate_circle(spring_thickness,resolution);
        }
      }
      translate([right*(y_rail_extrusion_width/2-spring_thickness),2-spring_thickness/2+spring_gap_width/2,0]) {
        rounded_square(spring_thickness,4,spring_thickness);
      }
    }
  }

  for(z=[top,bottom]) {
    mirror([0,1-z,0]) {
      translate([0,y_rail_extrusion_height/2]) {
        spring_profile();
      }

      for(x=[left,right]) {
        mirror([1-x,0,0]) {
          translate([y_rail_extrusion_width/2,y_rail_extrusion_height/4,0]) {
            rotate([0,0,-90]) {
              spring_profile();
            }
          }
        }
      }
    }
  }

  difference() {
    gap_width = cavity_height - y_rail_extrusion_height;
    rounded_square(body_width,body_height,wall_thickness*8);
    rounded_square(cavity_width,cavity_height,gap_width);
  }
}

module bevel(outer,inner,height,res=resolution) {
  hull() {
    translate([0,0,-height-0.05]) {
      hole(outer,0.1,res);
    }
    translate([0,0,-0.05]) {
      hole(inner,0.1,res);
    }
  }
}

module mid_air_hole(shaft_diam,head_diam,layer_height=0.2,depth=50,resolution=32) {
  translate([0,0,-depth/2]) {
    hole(shaft_diam,depth,resolution);
  }
  translate([0,0,depth/2]) {
    hole(head_diam,depth,resolution);
  }
  intersection() {
    hole(head_diam,layer_height*8,resolution);
    union() {
      cube([shaft_diam,head_diam+1,layer_height*2],center=true);
      cube([shaft_diam,shaft_diam,layer_height*4],center=true);
      hole(shaft_diam,layer_height*6,8);
    }
  }
}


module line_bearing(resolution=16) {
  module profile() {
    difference() {
      translate([line_bearing_diam/4,0]) {
        square([line_bearing_diam/2,line_bearing_thickness], center=true);
      }
      translate([line_bearing_inner/4,0]) {
        square([line_bearing_inner/2,line_bearing_thickness+1], center=true);
      }

      // groove
      translate([line_bearing_diam/2,0,0]) {
        rotate([0,0,0]) {
          accurate_circle(1,6);
        }
      }
    }
  }

  rotate_extrude(convexity=3,$fn=resolution) {
    profile();
  }

  // hole(line_bearing_diam,line_bearing_thickness,resolution);
  // hole(line_bearing_inner,line_bearing_thickness+1,resolution);
}

module stepper28BYJ(shaft_angle) {
  cable_distance_from_face = 1.75;
  cable_diam    = 1;
  num_cables    = 5;
  cable_pos_x   = [-2.4,-1.2,0,1.2,2.4];
  cable_colors  = ["yellow","orange","red","pink","royalblue"];
  cable_spacing = 1.2;
  cable_sample_len = 5;
  cable_opening_width = 7.3;

  resolution = 32;

  module position_at_flange_centers() {
    for(side=[left,right]) {
      translate([side*(byj_hole_spacing/2),0,0]) {
        children();
      }
    }
  }

  color("lightgrey") {
    // main body
    translate([0,0,-byj_height/2]) {
      hole(byj_body_diam,byj_height,resolution*1.25);
    }

    // flanges
    translate([0,0,-byj_flange_thickness/2]) {
      linear_extrude(height=byj_flange_thickness,center=true,convexity=3) {
        difference() {
          hull() {
            position_at_flange_centers() {
              accurate_circle(byj_flange_diam,resolution/2);
            }
          }
          position_at_flange_centers() {
            accurate_circle(byj_flange_hole_diam,resolution/2);
          }
        }
      }
    }

    // shaft base
    translate([0,-byj_shaft_from_center,0]) {
      hole(byj_shoulder_diam,byj_shoulder_height*2,resolution);
    }
  }

  // shaft
  color("gold") {
    translate([0,-byj_shaft_from_center,0]) {
      rotate([0,0,shaft_angle]) {
        difference() {
          hole(byj_shaft_diam,(byj_shaft_len+byj_shoulder_height)*2,resolution);

          translate([0,0,byj_shoulder_height+byj_shaft_len]) {
            for(y=[left,right]) {
              translate([0,y*byj_shaft_diam/2,0]) {
                cube([byj_shaft_diam,byj_shaft_flat_cut_depth*2,byj_shaft_flat_len*2],center=true);
              }
            }
          }
        }
      }
    }
  }

  // hump
  translate([0,byj_body_diam/2,-byj_hump_height/2-0.05]) {
    color("dodgerblue") {
      difference() {
        cube([byj_hump_width,byj_hump_depth*2,byj_hump_height],center=true);

        translate([0,byj_hump_depth,byj_hump_height/2-cable_distance_from_face-cable_diam/2]) {
          rotate([90,0,0]) {
            hull() {
              for(x=[left,right]) {
                translate([x*(cable_opening_width/2-cable_diam/2),0,0]) {
                  hole(cable_diam+0.1,8,10);
                }
              }
            }
          }
        }
      }
    }
  }

  // hump cables
  translate([0,byj_body_diam/2+byj_hump_depth,-cable_distance_from_face-cable_diam/2]) {
    rotate([90,0,0]) {
      for(c=[0:num_cables-1]) {
        translate([cable_pos_x[c],0,0]) {
          color(cable_colors[c]) {
            hole(cable_diam,cable_sample_len*2,8);
          }
        }
      }
    }
  }
}

tuner_hole_to_shoulder = 22.5;
wire_hole_diam = 2;

tuner_thin_diam = 6;
tuner_thin_len_past_hole = 5;
tuner_thin_len = tuner_hole_to_shoulder + tuner_thin_len_past_hole;
tuner_thin_pos = tuner_hole_to_shoulder/2-tuner_thin_len_past_hole/2;

tuner_thick_diam = 10;
tuner_thick_len = 10;
tuner_thick_pos = tuner_hole_to_shoulder-tuner_thick_len+tuner_thick_len/2;

tuner_body_diam = 15;
tuner_body_thickness = 9;
tuner_body_square_len = 10;
tuner_body_pos = -tuner_hole_to_shoulder-tuner_body_thickness/2;

tuner_anchor_screw_hole_thickness = 2;
tuner_anchor_screw_hole_diam = 2;
tuner_anchor_diam = 6;
tuner_anchor_screw_hole_pos_x = -tuner_hole_to_shoulder-tuner_anchor_screw_hole_thickness/2;
tuner_anchor_screw_hole_pos_y = -tuner_body_diam/2;
tuner_anchor_screw_hole_pos_z = -tuner_body_diam/2;

module tuner_anchor_hole_positioner_relative_to_tuner() {
  translate([tuner_anchor_screw_hole_pos_x,tuner_anchor_screw_hole_pos_y,tuner_anchor_screw_hole_pos_z]) {
    rotate([0,90,0]) {
      children();
    }
  }
}

module tuner() {
  adjuster_narrow_neck_len = 2;
  adjuster_len = 24 - tuner_body_diam + adjuster_narrow_neck_len;
  adjuster_large_diam = 8;
  adjuster_tuner_thin_diam = 6;
  adjuster_x = tuner_body_pos;
  adjuster_y = tuner_body_square_len/2;
  adjuster_shaft_z = tuner_body_diam/2+adjuster_len/2;
  adjuster_paddle_len = 20;
  adjuster_paddle_z = adjuster_shaft_z + adjuster_len/2 + adjuster_paddle_len/2;
  adjuster_paddle_width = 17.8;
  adjuster_paddle_thickness = adjuster_tuner_thin_diam;

  module body() {
    //% translate([-tuner_hole_to_shoulder/2,-tuner_thick_diam,0]) rotate([0,90,0]) cylinder(r=tuner_thin_diam/4,h=tuner_hole_to_shoulder,center=true);

    // thin shaft
    translate([-tuner_thin_pos,0,0]) rotate([0,90,0])
      hole(tuner_thin_diam,tuner_thin_len,resolution);

    // thick shaft (area to clamp)
    translate([-tuner_thick_pos,0,0]) rotate([0,90,0])
      hole(tuner_thick_diam,tuner_thick_len,resolution);

    // body
    translate([tuner_body_pos,0,0]) {
      hull() {
        rotate([0,90,0]) {
          hole(tuner_body_diam,tuner_body_thickness,resolution);
        }
        translate([0,tuner_body_square_len/2,0]) {
          cube([tuner_body_thickness,tuner_body_square_len,tuner_body_diam],center=true);
        }
      }
    }

    // anchor screw hole
    hull() {
      translate([tuner_anchor_screw_hole_pos_x,0,0]) {
        rotate([0,90,0])
          hole(tuner_thick_diam,tuner_anchor_screw_hole_thickness);
      }
      tuner_anchor_hole_positioner_relative_to_tuner() {
        hole(tuner_anchor_diam,tuner_anchor_screw_hole_thickness,resolution);
      }
    }

    // twist adjuster
    translate([adjuster_x,adjuster_y,adjuster_shaft_z]) {
      hull() {
        translate([0,0,-adjuster_len/2-.5]) hole(adjuster_large_diam,1,resolution);
        translate([0,0,+adjuster_len/2-.5]) hole(adjuster_tuner_thin_diam,1,resolution);
      }
      // paddle, representing space taken when rotated
      /*
      hull() {
        //translate([0,0,adjuster_paddle_len/2]) cylinder(r=adjuster_paddle_width/2,h=1,center=true);
        //translate([0,0,1]) cylinder(r=adjuster_paddle_thickness/2,h=1,center=true);
        translate([0,0,adjuster_paddle_len-.5]) cube([adjuster_paddle_width,adjuster_paddle_thickness,1],center=true);
        translate([0,0,adjuster_len/2]) cube([adjuster_paddle_thickness,adjuster_paddle_thickness,1],center=true);
      }
      */
    }
  }

  module holes() {
    cylinder(r=wire_hole_diam/3,h=tuner_thin_diam*2,center=true);

    translate([tuner_anchor_screw_hole_pos_x,tuner_anchor_screw_hole_pos_y,tuner_anchor_screw_hole_pos_z]) rotate([0,90,0])
      hole(tuner_anchor_screw_hole_diam,tuner_anchor_screw_hole_thickness+1,8);
  }

  difference() {
    body();
    holes();
  }
}

v_slot_depth     = 1.80;
//v_slot_gap       = 5.68;
v_slot_width     = 9.5;
v_slot_gap       = v_slot_width-v_slot_depth*2;
v_slot_opening   = 6.2;
v_slot_cavity_depth = 12.2/2;
v_slot_center_square = 2*(10-v_slot_cavity_depth-v_slot_depth+v_slot_depth);

module groove_profile() {
  square([v_slot_depth*3,v_slot_opening],center=true);
  hull() {
    square([v_slot_depth*2,v_slot_gap],center=true);
    translate([0,0,0]) {
      square([0.00001,v_slot_width],center=true);
    }
  }

  opening_behind_slot = 1.64;
  opening_behind_slot_width = v_slot_gap+(v_slot_cavity_depth-opening_behind_slot-v_slot_depth)*2;

  for(side=[left,right]) {
    translate([side*v_slot_depth,0,0]) {
      hull() {
        translate([side*(v_slot_cavity_depth-v_slot_depth)/2,0,0]) {
          square([v_slot_cavity_depth-v_slot_depth,v_slot_gap],center=true);
        }
        translate([side*opening_behind_slot/2,0,0]) {
          square([opening_behind_slot,opening_behind_slot_width],center=true);
        }
      }
    }
  }
  /*
  translate([0,0,0]) {
    % color("purple", 0.3) {
      # square([2*(v_slot_cavity_depth-v_slot_depth+v_slot_depth),v_slot_gap],center=true);
    }
  }
  */
}

module extrusion_2020_profile() {
  width = 20;
  height = 20;

  difference() {
    square([width,height],center=true);

    accurate_circle(4.2,16);

    for(y=[top,bottom]) {
      translate([0,y*height/2,0]) {
        rotate([0,0,90]) {
          groove_profile();
        }
      }
    }

    for(x=[left,right]) {
      translate([x*width/2,0]) {
        rotate([0,0,0]) {
          groove_profile();
        }
      }
    }
  }
}

module extrusion_2040_profile() {
  width = 40;
  height = 20;

  base_unit = 20;
  open_space_between_sides = base_unit-v_slot_depth*2;
  difference() {
    square([width,height],center=true);

    square([5.4,open_space_between_sides],center=true);

    hull() {
      square([5.4,open_space_between_sides-1.96*2],center=true);
      square([12.2,5.68],center=true);
    }

    for(x=[left,right]) {
      translate([x*width/4,0]) {
        accurate_circle(4.2,16);

        for(y=[top,bottom]) {
          translate([0,y*height/2,0]) {
            rotate([0,0,90]) {
              groove_profile();
            }
          }
        }
      }

      translate([x*width/2,0]) {
        rotate([0,0,0]) {
          groove_profile();
        }
      }
    }
  }
}

module extrusion_4040_profile() {
  width = 40;
  height = 40;

  base_unit = 20;
  open_space_between_sides = height-v_slot_depth*2;
  difference() {
    square([width,height],center=true);

    square([5.4,open_space_between_sides],center=true);
    square([open_space_between_sides,5.4],center=true);

    hull() {
      square([5.4,base_unit-v_slot_depth*2-1.96*2],center=true);
      square([12.2,5.68],center=true);
    }

    for(x=[left,right],y=[front,rear]) {
      translate([x*(base_unit/2),y*(base_unit/2),0]) {
        accurate_circle(4.2,16);

        translate([-x*(base_unit/2),0,0]) {
          groove_profile();
        }
        translate([0,-y*(base_unit/2),0]) {
          rotate([0,0,90]) {
            groove_profile();
          }
        }
      }
    }

    for(r=[0,90,180,270]) {
      rotate([0,0,r]) {
        translate([base_unit/2-v_slot_center_square/2,base_unit/2-v_slot_center_square/2,0]) {
          round_corner_filler_profile(v_slot_center_square);
        }
        rotate([0,0,45]) {
          translate([-5,0,0]) {
            square([10,10],center=true);
          }
        }
      }
    }

    for(x=[left,right]) {
      for(y=[top,bottom]) {
        translate([x*base_unit/2,y*height/2,0]) {
          rotate([0,0,90]) {
            groove_profile();
          }
        }

        translate([x*width/2,y*base_unit/2]) {
          rotate([0,0,0]) {
            groove_profile();
          }
        }
      }
    }
  }
}

module corner_bracket_2020_base() {
  side = 20;
  //thickness = (side - m5_fsc_head_diam) / 2 - 0.5; // 4.5mm
  thickness = 4;
  wall_thickness = extrude_width*3*2;

  module body() {
    intersection() {
      hull() {
        translate([0,side/2-thickness/4,0]) {
          cube([side,thickness/2,side],center=true);
        }
        translate([0,0,-side/2+thickness/4]) {
          cube([side,side,thickness/2],center=true);
        }
      }
      rounded_cube(side,side,side,thickness,resolution);
    }
  }

  module holes() {
    translate([0,-side/2,side/2]) {
      //cube([side - wall_thickness*2,(side-thickness)*2,(side-thickness)*2],center=true);
      rounded_cube(side - wall_thickness*2,(side-thickness)*2,(side-thickness)*2,thickness,resolution);
    }
  }

  difference() {
    body();
    holes();
  }
}

module corner_bracket_2020_m3() {
  side = 20;
  //thickness = (side - m5_fsc_head_diam) / 2 - 0.5; // 4.5mm
  thickness = 4;

  module body() {
    corner_bracket_2020_base();
  }

  module holes() {
    translate([0,0,-side/2+thickness]) {
      hole(3+0.4,20,resolution);
    }

    translate([0,side/2-thickness,0]) {
      rotate([90,0,0]) {
        hole(3+0.4,20,resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module corner_bracket_2020() {
  side = 20;
  //thickness = (side - m5_fsc_head_diam) / 2 - 0.5; // 4.5mm
  thickness = 4;

  module body() {
    corner_bracket_2020_base();
  }

  module holes() {
    translate([0,0,-side/2+thickness]) {
      m5_countersink_screw();
      hole(5+0.4,20,resolution);
    }

    translate([0,side/2-thickness,0]) {
      rotate([90,0,0]) {
        m5_countersink_screw();
        hole(5+0.4,20,resolution);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module extrusion_2020(len) {
  color("silver") {
    linear_extrude(height=len,center=true,convexity=4) {
      extrusion_2020_profile();
    }
  }
}

module extrusion_2040(len) {
  color("silver") {
    linear_extrude(height=len,center=true,convexity=4) {
      extrusion_2040_profile();
    }
  }
}

module extrusion_4040(len) {
  color("silver") {
    linear_extrude(height=len,center=true,convexity=4) {
      extrusion_4040_profile();
    }
  }
}

module ptfe_bushing_profile_for_2040_extrusion() {
  width = 40;
  height = 20;
  bushing_from_extrusion_corner = ptfe_bushing_diam/2+0.5;

  // PTFE bushings
  // short side bushings
  for(x=[left,right]) {
    for (z=[top,bottom]) {
      translate([x*(width/2+ptfe_bushing_diam/2-ptfe_bushing_preload_amount),z*(height/2-bushing_from_extrusion_corner)]) {
        accurate_circle(ptfe_bushing_diam,8);
      }
    }
  }

  // long side bushings
  for(x=[left,right]) {
    for (z=[top,bottom]) {
      translate([x*(width/2-bushing_from_extrusion_corner),z*(height/2+ptfe_bushing_diam/2-ptfe_bushing_preload_amount)]) {
        accurate_circle(ptfe_bushing_diam,8);
      }
    }
  }
}

nema17_side = 42;
nema17_len = 48;
nema17_hole_spacing = 31;
nema17_shoulder_diam = 22;
nema17_shoulder_height = 2;
nema17_screw_diam = 3;
nema17_shaft_diam = 5;
nema17_shaft_len = 26;

module motor_nema17(nema17_len) {
  module body() {
    translate([0,0,-nema17_len/2]) {
      intersection() {
        cube([nema17_side,nema17_side,nema17_len],center=true);
        hole(53,nema17_len+1,resolution*2);
      }
    }
    hole(nema17_shoulder_diam,nema17_shoulder_height*2,resolution);

    translate([0,0,nema17_shaft_len/2]) {
      hole(nema17_shaft_diam,nema17_shaft_len,16);
      // hole(line_pulley_diam,line_pulley_height,16);
    }
  }

  module holes() {
    for(end=[left,right]) {
      for(side=[front,rear]) {
        translate([nema17_hole_spacing/2*side,nema17_hole_spacing/2*end,0]) cylinder(r=nema17_screw_diam/2,h=100,center=true);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

nema14_side = 35.3;
nema14_len = 44;
nema14_hole_spacing = 26;
nema14_shoulder_diam = 22;
nema14_shoulder_height = 2;
nema14_screw_diam = 3;
nema14_shaft_diam = 5;
nema14_shaft_len = 20;

module motor_nema14() {
  difference() {
    translate([0,0,-nema14_len/2]) cube([nema14_side,nema14_side,nema14_len],center=true);
    for(end=[left,right]) {
      for(side=[front,rear]) {
        translate([nema14_hole_spacing/2*side,nema14_hole_spacing/2*end,0]) cylinder(r=nema14_screw_diam/2,h=100,center=true);
      }
    }
  }
  hole(nema14_shoulder_diam,nema14_shoulder_height*2,16);

  translate([0,0,nema14_shaft_len/2]) {
    hole(nema14_shaft_diam,nema14_shaft_len,16);
    // hole(line_pulley_diam,line_pulley_height,16);
  }
}

round_nema14_body_diam = 36.5;
round_nema14_body_len = 19.5;
round_nema14_hole_spacing = 43.9;
round_nema14_shoulder_diam = 16;
round_nema14_shoulder_height = 2;
round_nema14_shaft_diam = 5;
round_nema14_shaft_len = 15-2; // -2 is the shoulder height
round_nema14_shaft_from_center = 0;
round_nema14_shaft_flat_depth = 0.5;
round_nema14_shaft_flat_thickness = round_nema14_shaft_diam-round_nema14_shaft_flat_depth;
round_nema14_shaft_flat_offset = -round_nema14_shaft_flat_depth/2;
round_nema14_shaft_flat_len = 10;
round_nema14_flange_thickness = 1.5;
round_nema14_flange_diam = 9;

module round_nema14(shaft_angle) {
  cable_colors  = ["dimgrey","red","blue","green"];
  metal_top_bottom_thickness = 3;
  cable_diam    = 1;
  cable_spacing = cable_diam+0.3;
  cable_pos_x = [ -1.5, -0.5, 0.5, 1.5 ];
  num_cables    = 4;

  module body() {
    translate([0,0,-round_nema14_body_len/2]) {
      color("dimgray") hole(round_nema14_body_diam-1,round_nema14_body_len-1,resolution);
      for(z=[top,bottom]) {
        translate([0,0,z*(round_nema14_body_len/2-metal_top_bottom_thickness/2)]) {
          color("lightgrey") hole(round_nema14_body_diam,metal_top_bottom_thickness,resolution);
        }
      }
    }
    color("lightgrey") {
      hole(round_nema14_shoulder_diam,round_nema14_shoulder_height*2,resolution);
      translate([0,0,round_nema14_shaft_len/2+round_nema14_shoulder_height]) {
        hole(round_nema14_shaft_diam,round_nema14_shaft_len,resolution);
      }

      translate([0,0,-round_nema14_flange_thickness/2]) {
        linear_extrude(height=round_nema14_flange_thickness,center=true,convexity=3) {
          difference() {
            hull() {
              accurate_circle(round_nema14_shoulder_diam+7,resolution);
              for(side=[left,right]) {
                translate([side*round_nema14_hole_spacing/2,0,0]) {
                  accurate_circle(round_nema14_flange_diam,resolution);
                }
              }
            }
            for(side=[left,right]) {
              translate([side*round_nema14_hole_spacing/2,0,0]) {
                accurate_circle(3,12);
              }
            }
          }
        }
      }
    }

    translate([0,round_nema14_body_diam/2,-round_nema14_body_len+metal_top_bottom_thickness]) {
      color("ivory") cube([cable_spacing*5,3,cable_spacing*2],center=true);
      translate([0,0,0]) {
        rotate([90,0,0]) {
          for(c=[0:num_cables-1]) {
            translate([cable_pos_x[c]*cable_spacing,0,0]) {
              color(cable_colors[c]) {
                hole(cable_diam,15,8);
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    translate([0,0,round_nema14_shoulder_height+round_nema14_shaft_len]) {
      rotate([0,0,0]) {
        translate([0,round_nema14_shaft_diam/2,0]) {
          cube([round_nema14_shaft_diam+1,round_nema14_shaft_flat_depth*2,round_nema14_shaft_flat_len*2],center=true);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

mech_endstop_tiny_width = 5.5;
mech_endstop_tiny_length = 13;
mech_endstop_tiny_height = 7;
mech_endstop_tiny_mounting_hole_diam =2;
mech_endstop_mounting_hole_spacing_y = 6.35;
mech_endstop_tiny_mounting_hole_from_top = 5.1;

module position_mech_endstop_tiny_mount_holes() {
  for(y=[front,rear]) {
    translate([0,y*(mech_endstop_mounting_hole_spacing_y/2),-mech_endstop_tiny_mounting_hole_from_top]) {
      rotate([0,90,0]) {
        children();
      }
    }
  }
}

module mech_endstop_tiny() {
  spring_angle = 20;
  spring_length = mech_endstop_tiny_length+1;
  button_from_spring_hinge_end = 4.5;
  button_length = 1;

  module body() {
    color("dimgrey") {
      translate([0,0,-mech_endstop_tiny_height/2]) {
        cube([mech_endstop_tiny_width,mech_endstop_tiny_length,mech_endstop_tiny_height],center=true);
      }
    }

    // contacts
    pin_width = 0.85;
    for(y=[front,0,rear]) {
      translate([0,y*(mech_endstop_tiny_length/2-0.9-pin_width/2),-mech_endstop_tiny_height]) {
        color("silver") {
          cube([0.85,0.85,4],center=true);
        }
      }
    }

    translate([0,mech_endstop_tiny_length/2,0]) {
      translate([0,-button_from_spring_hinge_end,0]) {
        color("red") {
          cube([mech_endstop_tiny_width-2.5,button_length,1],center=true);
        }
      }

      translate([0,-1,0]) {
        rotate([-spring_angle,0,0]) {
          translate([0,-spring_length/2,0]) {
            color("silver") {
              difference() {
                cube([mech_endstop_tiny_width-1,spring_length,0.2],center=true);
                hole_diam = mech_endstop_tiny_width-1-2.5;
                hull() {
                  translate([0,spring_length/2-hole_diam/2,0]) {
                    hole(hole_diam,1,12);
                  }
                  translate([0,-2,0]) {
                    hole(hole_diam,1,12);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    for(y=[front,rear]) {
      translate([0,y*(mech_endstop_mounting_hole_spacing_y/2),-mech_endstop_tiny_mounting_hole_from_top]) {
        rotate([0,90,0]) {
          hole(mech_endstop_tiny_mounting_hole_diam,mech_endstop_tiny_width+1,8);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module mini_v_wheel() {
  difference() {
    hull() {
      hole(mini_v_wheel_od,mini_v_wheel_flat_width,resolution);
      hole(mini_v_wheel_smaller_od,mini_v_wheel_thickness,resolution);
    }
    hole(mini_v_wheel_id,mini_v_wheel_thickness+1,resolution);
  }
}

buck_conv_hole_spacing_x = 16.4; // untested
buck_conv_hole_spacing_y = 30; // untested
buck_conv_hole_diam = 3;
buck_conv_width = 21.2; // sample more boards
buck_conv_length = 43.1; // sample more boards
buck_conv_overall_height = 14; // screw on pot sticks up highest

module buck_converter() {
  board_thickness = 1.3;

  cap_diam = 8;
  cap_height = 11;
  cap_coords = [
    [left*2,rear*(buck_conv_length/2-cap_diam/2-1),board_thickness+cap_height/2],
    [left*0.5,front*(buck_conv_length/2-cap_diam/2-1),board_thickness+cap_height/2],
  ];

  pot_y = 9.5;
  pot_x = 4.5;
  pot_z = 10;
  pot_coord = [-buck_conv_width/2+pot_x/2,buck_conv_length/2-19+pot_y/2,board_thickness+pot_z/2];

  pot_screw_diam = 2.3;
  pot_screw_height = 1.55;

  module body() {
    translate([0,0,board_thickness/2]) {
      color("green") cube([buck_conv_width,buck_conv_length,board_thickness],center=true);
    }

    for(coord=cap_coords) {
      translate(coord) {
        color("lightgrey") hole(cap_diam,cap_height,resolution);
      }
    }

    translate(pot_coord) {
      color("#229") cube([pot_x,pot_y,pot_z],center=true);

      translate([-pot_x/2+pot_screw_diam/2,-pot_y/2+pot_screw_diam/2,pot_z/2+pot_screw_height/2]) {
        color("gold") hole(pot_screw_diam,pot_screw_height,12);
      }
    }

    coil_side = 12.25;
    coil_height = 7;
    translate([buck_conv_width/2-coil_side/2-1.5,buck_conv_length/2-coil_side/2-10.3,board_thickness+coil_height/2]) {
      color("#555") rounded_cube(coil_side,coil_side,coil_height,3,16);
    }

    fet_width = 8.5;
    fet_length = 9.5;
    fet_height = 3.3;
    fet_plate_width = fet_width + 1.3;
    fet_plate_height = 1.3;
    translate([-buck_conv_width/2,-buck_conv_length/2+fet_length/2+10.4,board_thickness]) {
      translate([2.6+fet_width/2,0,fet_plate_height+fet_height/2]) {
        color("#555") cube([fet_width,fet_length,fet_height],center=true);
      }
      translate([1+fet_plate_width/2,0,fet_plate_height/2]) {
        color("lightgrey") cube([fet_plate_width,fet_length,fet_plate_height],center=true);
      }
    }
  }

  module holes() {
    for(side=[front,rear]) {
      translate([side*buck_conv_hole_spacing_x/2,side*buck_conv_hole_spacing_y/2,0]) {
        hole(buck_conv_hole_diam,board_thickness*3,resolution);
      }

      for(x=[left,right]) {
        translate([x*(buck_conv_width/2-2),side*(buck_conv_length/2-2),board_thickness]) {
          hole(1,board_thickness*3,12);

          color("lightgrey") cube([4,4,0.1],center=true);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module position_buck_converter_holes() {
  for(x=[left,right],y=[front,rear]) {
    translate([x*(buck_conv_hole_spacing_x/2),y*(buck_conv_hole_spacing_y/2),0]) {
      children();
    }
  }
}

module countersink_screw(actual_shaft_diam,head_diam,head_depth,length) {
  loose_tolerance = 0.4;
  shaft_hole_diam = actual_shaft_diam + loose_tolerance;

  hole(shaft_hole_diam,length*2,resolution);
  diff = head_diam-shaft_hole_diam;
  hull() {
    hole(shaft_hole_diam,diff+head_depth*2,resolution);
    hole(head_diam,head_depth*2,resolution);
  }
}

module m3_countersink_screw(length=countersink_default_length) {
  countersink_screw(3,m3_fsc_head_diam,0.5,length);
}

module m5_countersink_screw(length=countersink_default_length) {
  countersink_screw(5,m5_fsc_head_diam,0.5,length);
}

module m6_countersink_screw(length=countersink_default_length) {
  countersink_screw(6,m6_fsc_head_diam,0.5,length);
}
