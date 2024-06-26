clear all;
close all;


function world = gen_world(N)
  world = sparse(zeros(N));
  world(end,:) = world(:,end) = world(1,:) = world(:,1) =1;
  %world(80:end-1, 50) = 2;
  world(30:50, 30:50) = 2;
  %world(40:end-1, 2:20)= 2;
  %world(1,1) = 2;
  %world(20:40,20:40) = 2;
endfunction

function nutrient_matrix = gen_nutrients(size_world, initial_value);
  nutrient_matrix = initial_value * ones(size_world);
endfunction

function Pd = cell_division(nutrient_matrix, K,world)
  Pd = sparse(zeros(size(nutrient_matrix)));
  Pd(world == 2) = nutrient_matrix(world == 2) ./ (nutrient_matrix(world == 2)+K);
endfunction


function new_nutrient_matrix = update_nutrient_matrix(world,nutrient_matrix,Cs,F,a,layer_thickness, D,dt)
  [bacteria_row, bacteria_col] = find(world == 2);


  new_nutrient_matrix = nutrient_matrix;

  for bacteria = 1:length(bacteria_row)
    bacteria_row(bacteria);, bacteria_col(bacteria);
    distances = [];
    try
      distances(1) = bacteria_row(bacteria) - find(world(1:bacteria_row(bacteria), bacteria_col(bacteria)) == 0, 1, "last"); % Above
    catch
      distances(1) = 0;

    end_try_catch

    try
      distances(2) = find(world(bacteria_row(bacteria):end, bacteria_col(bacteria)) == 0, 1, "first")-1; % Under
    catch
      distances(2) = 0;
    end_try_catch

    try
      distances(3) = bacteria_col(bacteria) - find(world(bacteria_row(bacteria), 1:bacteria_col(bacteria)) == 0, 1, "last"); % Left
    catch
      distances(3) = 0;
    end_try_catch
    try
      distances(4) = find(world(bacteria_row(bacteria), bacteria_col(bacteria):end) == 0,1, "first")-1; % Right

    catch
      distances(4) = 0;
    end_try_catch

    distances(5) = sqrt(distances(1)^2 + distances(3)^2);
    distances(6) = sqrt(distances(1)^2 + distances(3)^2);

      % Get bottom corner
    distances(7) = sqrt(distances(1)^2 + distances(4)^2);
    distances(8) = sqrt(distances(1)^2 + distances(4)^2);
    distances(distances == 0) = (layer_thickness/a);
    effectieve_afstand = sum(1 ./ (distances./a).^2)^(-1);

    cs = (sqrt(Cs) - sqrt(F* (1/8)*effectieve_afstand))^2;
    new_nutrient_matrix(bacteria_row(bacteria), bacteria_col(bacteria)) = cs;

  endfor
  new_nutrient_matrix = new_nutrient_matrix + D * dt * del2(nutrient_matrix);
endfunction


function world = new_gen(world, Pd);
  random_numbers = zeros(size(Pd));
  non_nul_indices = (Pd ~= 0);
  nul_indices = (Pd == 0);
  random_numbers(non_nul_indices) = rand(size(Pd(Pd ~= 0)));

  Pd(Pd ~= 0) = (random_numbers(Pd ~= 0) < Pd(Pd ~= 0));

  neighbor_numbers = zeros(size(world));
  neighbor_numbers(world == 0) = rand(size(world(world == 0)));
  maxval = zeros(size(neighbor_numbers));
  for delta_x = -1:1
    for delta_y = -1:1
      maxval = max(maxval, circshift(neighbor_numbers, [delta_y, delta_x]));
    endfor
  endfor

  Pd(Pd != 1 & world !=1 & (ismember(neighbor_numbers, maxval(neighbor_numbers == 0 & Pd == 1)))) = 1;
  world(Pd == 1) = 2;
endfunction



function world = cell_erosion(world, strength, stress)
  Pe = 1 / (1+(strength / stress));
  rand_mask = rand(size(world));
  eroding_cells = (rand_mask < Pe) & ( world == 2);
  eroding_cells_layer = eroding_cells & ((circshift(world, [0,-1]) == 0) | (circshift(world, [0,1]) == 0) | (circshift(world, [1,0]) == 0) | (circshift(world, [-1,0]) == 0));
  world(eroding_cells_layer) = 0;
endfunction



% Constanten
N = 100; % Size world
dB = 1e-5 ; % Layer size

r = 0.1; % Biofilm sterkte
s = 0.2; % Stress


D = 1e-9; % Diffusie rate
k = 0.01; % Nutrient update rate
C = 0.3; % Bulk concentratie
bacteria_size = 1e-6 % Formaat bacterie

dt = 0.1; %Tijdstap difussie

K = 1000; % Half-saturatie constante

F = (k * bacteria_size^2) / (2*D*K) % Dimensieloze parameter
Cs = C / K % Dimensieloze parameter
world = gen_world(N);
nutrient_matrix = gen_nutrients(N, C);

while world(world == 2) || (N / length(world(world == 2))) > 0.8

nutrient_matrix = update_nutrient_matrix(world,nutrient_matrix,Cs,F, bacteria_size,dB,D,dt);



Pd = (cell_division(nutrient_matrix, K,world))

world = sparse(new_gen(world, Pd));

world = full(cell_erosion(world, r,s));
pause(0.1)
break
endwhile

