% Bacteria colony model
%   Simulate the growth of different bacteria, in different enviroments
%
% Made by Ivar lottman en Ramon Reilman, bio-informatics year 1
% Date: first of july, 2024
% Teacher: Dave
% Version: 1.0

close all
clear all

% matrix getal defenitie
% 0 is water
% 1 is bodem
% 2 is vaste cell
% 3 is vrije cell
% testwereld initialisatie
data.wereld = sparse(zeros(50));
data.wereld(2,2) = 3;
data.wereld(end,:) = data.wereld(:,end) = data.wereld(:, 1) = data.wereld(1,:) = 1;
data.nut_matrix = 0;


% gui
button_color = [211 ,102,147]/255;
screensize = get(0.0, "screensize")(3:4);
data.fig = figure(
   "name", "Bacteria colony",
  "numbertitle", "off",
  "units", "pixels",
  "position", [(screensize(1) - 1200) / 2, (screensize(2) - 800) / 2, 1200, 800],
  "menubar", "none",
  "color", [216,176,235]/255,
  "buttondownfcn", @mouse_click
);

% Create axes
data.axs = axes(
  "units", "pixels",
  "position", [150, 0, 1050, 800]
);

% Create step button
data.step_btn = uicontrol(
  "units", "pixels",
  "position", [10, 740, 130, 55],
  "style", "pushbutton",
  "string", "Step",
  "backgroundcolor", button_color,
  "tooltipstring", "Take 1 step in the world",
  "callback", @step
);

% Stop and start button
data.play_stop_btn = uicontrol(
  "units", "pixels",
  "position", [10,555+125, 130, 55],
  "style", "togglebutton",
  "string", "Start",
  "backgroundcolor", button_color,
  "selectionhighlight", "off",
  "tooltipstring", "Start the cellular automaton",
  "callback", @play
);

% List of worlds
data.fun_settings = uicontrol(
  "units", "pixels",
  "position", [10,495+125, 130, 55],
  "style", "popupmenu",
  "string", {"Random world", "Empty world","Borderless world","Random substrate", "Corner spawns", "Cross", "Smily preset","Fall Preset"},
  "backgroundcolor", button_color,
  "selectionhighlight", "off",
  "fontsize", 8,
  "tooltipstring", "Generate preset/random worlds",
  "callback", @apply_settings
);


% Speed meter
data.speed_slider = uicontrol(
  "units", "pixels",
  "position", [10, 375+125, 130, 20],
  "style", "slider",
  "string", "speed",
  "value", 0.1,
  "tooltipstring", "Change time between the steps in seconds",
  "callback", @set_value,
  "backgroundcolor", button_color
);

% Speed meter label
data.speed_value = uicontrol (
  "style", "text",
  "units", "pixels",
  "position", [10, 395+125, 130, 35],
  "backgroundcolor", [216,176,235]/255,
  "string", "time between step:\n 0s",
  "Foregroundcolor", [0,0,0]
);

% Slider for layer
data.dikte_slider = uicontrol(
  "units", "pixels",
  "position", [10, 305+125, 130, 20],
  "style", "slider",
  "string", "laag_dikte",
  "Min", 1,
  "Max", 11,
  "value", 5,
  "tooltipstring", "Change the thickness of layer between water and colony",
  "callback", @set_value,
  "backgroundcolor", button_color
);

% Label for layer
data.dikte_value = uicontrol (
  "style", "text",
  "units", "pixels",
  "position", [10, 325+125, 130, 35],
  "backgroundcolor", [216,176,235]/255,
  "string", "bulk layer thickness:\n 5 grid spaces",
  "Foregroundcolor", [0,0,0]
);

% Colony strength resistance
data.sterkte_col = uicontrol(
  "units", "pixels",
  "position", [27, 210+125, 40, 40],
  "style", "edit",
  "string", "0.13",
  "value", 0.09,
  "tooltipstring", "Amount a colony can resist erosion",
  "callback", @set_value,
  "backgroundcolor", button_color
);

% Colony stress
data.stress_col = uicontrol(
  "units", "pixels",
  "position", [95, 210+125, 40, 40],
  "style", "edit",
  "string", "0.12",
  "value", 0.12,
  "tooltipstring", "Amount a colony can resist erosion",
  "callback", @set_value,
  "backgroundcolor", button_color
);

% Label for erosion
data.erosion_label = uicontrol (
  "style", "text",
  "units", "pixels",
  "position", [10, 255+125, 130, 35],
  "backgroundcolor", [216,176,235]/255,
  "string", "Erosion resistance\n resistance     stress",
  "Foregroundcolor", [0,0,0]
);

% Calorie uptake of the bacteria
data.uptake = uicontrol(
  "units", "pixels",
  "position", [27, 125+125, 40, 40],
  "style", "edit",
  "string", "0.1",
  "value", 0.1,
  "tooltipstring", "Amount 1 bacteria eats nutrients (0.001-inf)",
  "callback", @set_value,
  "backgroundcolor", button_color
);

% Nutrient diffusion
data.diff_co = uicontrol(
  "units", "pixels",
  "position", [95, 125+125, 40, 40],
  "style", "edit",
  "string", "0.01",
  "value", 0.12,
  "tooltipstring", "Rate that nutrients diffuse through colony (0.001-inf)",
  "callback", @set_value,
  "backgroundcolor", button_color
);

% Label
data.nutrition_diff_label = uicontrol (
  "style", "text",
  "units", "pixels",
  "position", [10, 175+125, 130, 35],
  "backgroundcolor", [216,176,235]/255,
  "string", "Nutrient\n    uptake     Diffusion",
  "Foregroundcolor", [0,0,0]
);

% Concentration nutrients in water
data.bulk_c = uicontrol(
  "units", "pixels",
  "position", [10, 65+125, 130, 20],
  "style", "slider",
  "string", "bulk_c",
  "Min", 1,
  "Max", 20,
  "value", 2.6,
  "tooltipstring", "Concentration of nutrients in the water",
  "callback", @set_value,
  "backgroundcolor", button_color
);

% Label
data.bulk_value = uicontrol (
  "style", "text",
  "units", "pixels",
  "position", [10, 85+125, 130, 35],
  "backgroundcolor", [216,176,235]/255,
  "string", "nutrient concentration:\n 2.6",
  "fontsize", 8,
  "Foregroundcolor", [0,0,0]
);

% List of possible gradients to show
data.wanted_world = uicontrol(
  "units", "pixels",
  "position", [10, 435+125, 130, 55],
  "style", "popupmenu",
  "string", {"Bacteria colony","Nutrient gradient", "Dividing Chance"},
  "tooltipstring", "Generate a new world, randomized or empty with black or white tiles",
  "backgroundcolor", button_color,
  "fontsize", 8
);

% Save button
data.save = uicontrol(
  "units", "pixels",
  "position", [10, 60, 130, 55],
  "style", "pushbutton",
  "string", "Save World",
  "backgroundcolor", button_color,
  "tooltipstring", "Take 1 step in the world",
  "callback", @download_world
);

% Load world
data.load = uicontrol(
  "units", "pixels",
  "position", [10, 120, 130, 55],
  "style", "pushbutton",
  "string", "Load World",
  "backgroundcolor", button_color,
  "tooltipstring", "Take 1 step in the world",
  "callback", @upload_wereld
);

% Help page button
help_page = uicontrol(
  "units", "pixels",
  "position", [10,10,20,20],
  "style", "pushbutton",
  "string", "?",
  "backgroundcolor", [0.2,0.2,0.2],
  "foregroundcolor", [1,1,1],
  "tooltipstring", "Go to help page",

  "callback",@web_help
);
% display
data.img = imagesc(data.axs, data.wereld, [0, 3]);
axis(data.axs, "off");

% gui variable
guidata(data.fig, data);

function new_nutrient_matrix = update_nutrient_matrix(world,nutrient_matrix,k,layer_thickness, D, Cs)
  % --- update_nutrient_matrix (world, nutrient_matrix,k,layer_thickness,D,cs)
  %       Updates the nutrient concentrations for every cell in a colony
  %
  %

  % Find all bacteria in the world
  [bacteria_row, bacteria_col] = find(world == 2);

  % Create new matrix
  new_nutrient_matrix = zeros(size(world));

  % Loop through all bacteria
  for bacteria = 1:length(bacteria_row)
    bacteria_row(bacteria);, bacteria_col(bacteria);

    % Find the distance to the closest water or substrate in the Von Neumann directions
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


    % Add the layer thickness to distances
    distances += (layer_thickness);

    % Get harmonic mean of the distances
    effectieve_afstand = sum(1 ./ distances.^2)^(-1);

    % Calculate new concentration for every bacteria
    new_nutrient_matrix(bacteria_row(bacteria), bacteria_col(bacteria)) = Cs / (1+sqrt((k / (2*D)) * effectieve_afstand));

  endfor
endfunction


function world = new_gen(world, Pd);
  % --- new_gen(world, Pd)
  %       Generate a new world, with new divided cells
  %

  % Create a mmatrix that will include random numbers
  random_numbers = zeros(size(Pd));

  % Get the indices for 0's and non 0's
  non_nul_indices = (Pd ~= 0);
  nul_indices = (Pd == 0);

  % Fill matrix with random numbers
  random_numbers(non_nul_indices) = rand(size(Pd(Pd ~= 0)));

  % Get all cells that will divide.
  Pd(Pd ~= 0) = (random_numbers(Pd ~= 0) < Pd(Pd ~= 0));

  % Create array that will contain the random numbers for empty spaces, and 0's for spaces with cells.
  neighbor_numbers = zeros(size(world));
  neighbor_numbers(world == 0) = rand(size(world(world == 0)));

  % Matrix that will hold the heighest value in neighborhood
  maxval = zeros(size(neighbor_numbers));
  for delta_x = -1:1
    for delta_y = -1:1
      % Get max value
      maxval = max(maxval, circshift(neighbor_numbers, [delta_y, delta_x]));
    endfor
  endfor

  % Find the max value, and if a cell can divide, divide to the highest number.
  Pd(Pd != 1 & (world !=1 & world ~= 3) & (ismember(neighbor_numbers, maxval(neighbor_numbers == 0 & Pd == 1)))) = 1;

  % Change all 1's to state 2 for colony cells.
  world(Pd == 1) = 2;
endfunction



function world = cell_erosion(world, strength, stress)
  % --- cell_erosion (world, strength, stress)
  %       Calculates erosion probability and removes cells from world accordingly.
  %

  % Get the Probability of erosion
  Pe = 1 / (1+(strength / stress));

  % Get a matrix with random numbers
  rand_mask = rand(size(world));

  % Get cells that will be removed
  eroding_cells = (rand_mask < Pe) & ( world == 2);
  % Get all the cells at the surface of a colony
  eroding_cells_layer = eroding_cells & ((circshift(world, [0,-1]) == 0) | (circshift(world, [0,1]) == 0) | (circshift(world, [1,0]) == 0) | (circshift(world, [-1,0]) == 0));

  % Remove surfaced cells
  world(eroding_cells_layer) = 0;
endfunction


function Pd = cell_division(nutrient_matrix, K,world)
  % --- cell_division (nutrient_matrix, K, world)
  %       Calculates chance of cells dividing based on concentration of nutrients
  %

  % Calculate the probability of division
  Pd = sparse(zeros(size(nutrient_matrix)));
  Pd = nutrient_matrix ./ (nutrient_matrix+K);

endfunction


function play(source, event)
  % --- play(source, event)
  %       Lets the model continually play over time
  %       Until button is pressed again.
  %

  % Get data
  data = guidata(source);
  set_play(data);

  % while button is pressed
  while get(data.play_stop_btn, "Value")

  % Take a step
  data = take_step(source, event);

  % Render the world based on what user wants to see
  % Nutrients, world or cell division.

  if get(data.wanted_world, "Value")  == 1;
    set(data.img, "cdata", data.wereld);
  elseif get(data.wanted_world, "Value")  == 2
    set(data.img, "cdata", data.nut_matrix);
  else
    set(data.img, "cdata", data.Pd);
  endif
  pause(get(data.speed_slider, "Value"));
  guidata(data.fig, data);
endwhile

  if get(data.wanted_world, "Value") == 1
    set(data.img, "cdata", data.wereld);
  elseif get(data.wanted_world, "Value") == 2
    set(data.img, "cdata", data.nut_matrix)
  else
    set(data.img, "cdata", data.Pd)
  endif

  % Updates the data
  guidata(data.fig, data);
endfunction


function set_play(data)
  % --- set_play (data)
  %       Sets the color and label of the play/stop button
  %       This is based on the current state the world is in (playing/not playing)
  %

  % Gets value of play buttong and checks what it is
  if get(data.play_stop_btn, "Value");
    % If stop, change to red, label to stop and change the tooltipstring
    set(data.play_stop_btn, "string", "Stop");
    set(data.play_stop_btn, "backgroundcolor", [211-20 ,102-20,147-20]/255);
    set(data.play_stop_btn, "tooltipstring", "Stop the cellular automaton");


  elseif ~get(data.play_stop_btn, "Value");
    % If stop, change to purple, label to start and change the tooltipstring
    set(data.play_stop_btn, "string", "Start")
    set(data.play_stop_btn, "backgroundcolor", [211,102,147]/255)
    set(data.play_stop_btn, "tooltipstring", "Start the cellular automaton");

  endif

  % Updates figure
  guidata(data.fig, data);

endfunction


function step(source, event)
  % --- step(source, event)
  %       Take 1 step in the model
  %

  % Get data
  data = take_step(source, event);

  % Showcase the wanted data
  if get(data.wanted_world, "Value") == 1
    set(data.img, "cdata", data.wereld);
  elseif get(data.wanted_world, "Value") == 2
    set(data.img, "cdata", data.nut_matrix)
  else
    set(data.img, "cdata", data.Pd)
  endif

  % Update data
  guidata(data.fig, data);

endfunction


function data = take_step(source, event)
  % --- take_step (source, event)
  %       Takes 1 step in the world
  %       Updates all cells
  %

  % Get data and variables
  get_constants(source);
  data = guidata(source);

  % regels

  % Get new nutrient matrix
  data.nut_matrix = sparse(update_nutrient_matrix(data.wereld,data.nut_matrix,data.k,data.dB,data.D, data.Cs));

  % Get the dividing cells
  data.Pd = cell_division(data.nut_matrix, data.K,data.wereld);

  % Update the new world
  data.wereld = sparse(new_gen(data.wereld, data.Pd));
  data.wereld = cell_erosion(data.wereld, data.r,data.s);

  % Get neighbors
  underneibour = circshift(data.wereld,[-1,-1]);
  bovenneibour = circshift(data.wereld,[1,1]);

  % Update the moving cells
  data.wereld(data.wereld == 3 & (underneibour == 0 | underneibour == 3)) = 0;
  data.wereld(data.wereld == 3 & underneibour == 2 & bovenneibour == 2) = 2;
  data.wereld(data.wereld == 0 & bovenneibour == 3 & (underneibour == 1| underneibour == 2)) = 2;
  data.wereld(data.wereld == 0 & bovenneibour == 3) = 3;

endfunction


function get_constants(source)
  % --- get_constants
  %       Get all variables from the GUI
  %

  % Get data and the layer thickness
  data = guidata(source);
  data.dB = get(data.dikte_slider, "Value"); % Layer size

  % Get the resistance and erosion
  data.r = max(str2num(get(data.sterkte_col, "string")), 0.001);% Resistance
  data.s = max(str2num(get(data.stress_col, "string")),0.001); % Stress

  % Get the nutrient uptake and diffusion, and Concentration
  data.D = max(str2num(get(data.diff_co, "string")),0.001); % Diffusie rate
  data.k = max(str2num(get(data.uptake, "string")),0.001); % Nutrient update rate
  data.Cs = max(get(data.bulk_c, "Value"), 0.0001); % Bulk concentratie

  % Set the K
  data.K = 1; % Half-saturatie constant

  % Update data
  guidata(data.fig, data)
endfunction


function mouse_click(source, event)
  % --- mouse_click (source, event)
  %       Called when lmb is clicked
  %       Pauses world and converts [x,y] to [column,row]
  %       Turns tile to the other color on the column and row in the world
  %

  % Get data
  data = guidata(source);

  % Stop the world, if it's running
  set(data.play_stop_btn, "Value", 0);
  % Changes play/stop button
  set_play(data);

  % Gets the mouses position
  chords = get(source, "currentpoint");
  x = chords(1);
  y = chords(2);
  % Go from [x,y] to [column, row]
  px_per_column = 1050 / 50;
  px_per_row = 800/50;
  column = floor((x - 150)/21+1);
  row = floor((675-y-1)/px_per_row)+9;

  % Checks if row and column is inside the world
  if 1 <= column && column <= columns(data.wereld) && 1 <= row && row <= rows(data.wereld)

    % Changes states of grid cells
    switch (data.wereld(row, column))
      case 0
          data.wereld(row, column) = 1;
      case 1
          data.wereld(row, column) = 2;
      case 2
          data.wereld(row, column) = 3;
      case 3
          data.wereld(row, column) = 0;
      endswitch
  endif

  % Updates data.img and guidata
  set(data.img, "cdata", data.wereld);
  guidata(data.fig, data);

endfunction



function set_value(source, event)
  % --- set_value (source,event)
  %       Sets the labels to match correct value of slider.
  %

  % Get data, and changed value
  data = guidata(source);
  waarde = get(source, "Value");

  % Get button/slider
  what_button = get(source, "String");

  % Changes to labels to the new value
  if strcmp(what_button, "speed")
    set (data.speed_value, "string", sprintf("time between step:\n %.2fs", waarde));

  elseif strcmp(what_button, "laag_dikte")
    set(data.dikte_value, "string", sprintf("bulk layer thickness:\n %i grid spaces", waarde))

  elseif strcmp(what_button, "bulk_c")
    set(data.bulk_value, "string", sprintf("nutrient concentration:\n %i", waarde))
  endif

endfunction


function download_world(source, event)
  % --- download_world(source, event)
  %       User can save their current world
  %

  % Get data
  data = guidata(source);

  % Get name and folder
  [file_name, folder] = uiputfile(
  {"*.csv;*.txt", "text bestanden"},"bestandsnaam"
  )
  if file_name > 4
    % Save the world
    if endsWith(file_name, ".csv") | endsWith(file_name, ".txt")
      csvwrite([folder,file_name], data.wereld)

    endif
  endif
  % Update data
  guidata(source, data)
endfunction


function upload_wereld(source,event)
  % --- upload_wereld (source, event)
  %       Upload a previously saved world
  %

  % Get data and file_in_loadpath
  data = guidata(source);
  [file_name, folder] = uigetfile(
  {"*.csv;*.txt","csv bestand"},"bestandsnaam"
  );
  if endsWith(file_name, ".csv") | endsWith(file_name, ".txt")
    % Read the file
    world = csvread([folder,file_name]);
  endif

  % Set to world
  if isequal(size(world), size(data.wereld))
    data.wereld = world;
    set(data.img,"cdata", data.wereld);

    guidata(source, data);
   else
    errordlg("Ongeldig bestand");

  endif
endfunction


function apply_settings(source, event)
  % --- apply_settings (source, event)
  %       Change the world to a couple of pre saves.
  %

  % Get data
  data = guidata(source);

  % Get wanted world
  if get(data.fun_settings, "value") == 1
    % Random colonies
    data.wereld = sparse(50);

    rand_num = rand(50,50);

    data.wereld = (rand(50,50) < 0.4);
    data.wereld = data.wereld*2;
    data.wereld(end,:) = data.wereld(:,end) = data.wereld(:, 1) = data.wereld(1,:) = 1;
    single(data.wereld);

  elseif get(data.fun_settings, "value") == 2
  % Empty world with border
    data.wereld = sparse(zeros(50));
    data.wereld(end,:) = data.wereld(:,end) = data.wereld(:, 1) = data.wereld(1,:) = 1;

  elseif get(data.fun_settings, "value") == 3
    % Empty world without border
    data.wereld = sparse(zeros(50));

  elseif get(data.fun_settings, "value") == 4
    % Empty world with random substrate
    data.wereld = sparse(zeros(50));

    rand_num = rand(50,50);
    data.wereld = double((rand(50,50) < 0.1));

  % Next will be loading in worlds
  elseif get(data.fun_settings, "value") == 5
    data.wereld = csvread("pre_saves/corner_spawns.txt");


  elseif get(data.fun_settings, "value") == 6
    data.wereld = csvread("pre_saves/preset_cros.txt");


  elseif get(data.fun_settings, "value") == 7
    data.wereld = csvread("pre_saves/smily_preset.csv");


  elseif get(data.fun_settings, "value") == 8
    data.wereld = csvread("pre_saves/preset_fall.txt");

  endif

  % Update world, render and update data.
  data.wereld = sparse(data.wereld);
  set(data.img, "cdata", data.wereld);
  guidata(data.fig, data);
endfunction


function web_help(source, event)
  % --- web_help(source, event)
  %       Sends user to the wiki page
  %

  web("http://langers.nl/wiki/doku.php?id=biofilm_growth_2024:welkom");
endfunction
