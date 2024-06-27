world = sparse(zeros(50));
world(end, :) = 1;
world(end-1,5:9) = 2;


function world = create_boundary_layer(world)

  world(world == 0 & circshift(world, [-1,0]) == 2) = 5;
  world(world == 0 & (circshift(world, [0,1]) == 2 | circshift(world, [0,-1]) == 2)) = 5;
  world(world == 0 & (circshift(world, [-1,-1]) == 2 | circshift(world, [1,1]) == 2)) = 5;
  world(world == 0 & (circshift(world, [-1,1]) == 2 | circshift(world, [1,-1]) == 2)) = 5;
  %new_world(new_world == 0 & circshift(new_world, [0,2]) == 2 & circshift(new_world, [0,1]) == 0) = 5;
  %new_world(new_world == 0 & circshift(new_world, [-2,0]) == 2 & circshift(new_world, [-1,0]) == 0) = 5;
  %new_world(new_world == 0 & circshift(new_world, [0,-2]) == 2 & circshift(new_world, [0,-1]) == 0) = 5;
  %new_world(new_world == 0 & circshift(new_world, [-1,-1]) == 2 & circshift(new_world, [1,1]) == 0 & circshift(new_world, [-1,0]) == 0) = 5;
  %new_world(new_world == 0 & circshift(new_world, [-1,1]) == 2 & circshift(new_world, [1,-1]) == 0 & circshift(new_world, [-1,0]) == 0) = 5;
endfunction
function p_distances = get_p_distance(row_bacs, columns_bacs, x_row, y_column)
  p_distances = [];
  row_bacs, columns_bacs;
  x_position_layer = y_column(x_row == row_bacs);
  % Get x distance to bulk layer
  p_distances(1) = abs(sum(columns_bacs - x_position_layer(1)))+4;
  p_distances(2) = abs(sum(columns_bacs - x_position_layer(2)))+4;

  % Get y distance to bulk layer
  y_position_layer = x_row(y_column == columns_bacs);

  p_distances(3) = abs(sum(row_bacs - y_position_layer(1)))+4;
  p_distances(4) = abs(sum(row_bacs - 50))+1;

  % Get top corner distances
  p_distances(5) = sqrt(p_distances(1)^2 + p_distances(3)^2);
  p_distances(6) = sqrt(p_distances(1)^2 + p_distances(3)^2);

  % Get bottom corner
  p_distances(7) = sqrt(p_distances(1)^2 + p_distances(4)^2);
  p_distances(8) = sqrt(p_distances(1)^2 + p_distances(4)^2);
endfunction

function concentratie_world = prob_reproduction(world)
  F = 0.01;
  C = 1;

  [row_bacs, columns_bacs] = find(world == 2);
  [x_row, y_column] = find(world == 5);
  concentratie_world = world;
  for bacteria = 1:length(row_bacs)
    sided_p_distance = get_p_distance(row_bacs(bacteria), columns_bacs(bacteria), x_row, y_column);
    effective_depth = sided_p_distance
    concentratie = (C^0.5 - (F*0.1250*(sum(1./sided_p_distance.^2))^-1)^0.5)^2;
    concentratie_world(row_bacs(bacteria), columns_bacs(bacteria)) = concentratie/(concentratie+0.25);
  endfor
  concentratie_world(world < 5 & world > 1 & rand < concentratie_world) = 10;

endfunction

function world = next_gen(world)


endfunction


world = create_boundary_layer(world);
for x = 1:4
  imagesc(world)
  concentratie_world = prob_reproduction(world);
  world = next_gen(concentratie_world);

  pause(1)
endfor


