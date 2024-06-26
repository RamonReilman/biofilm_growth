%

% matrix getal defenitie
% 0 is water
% 1 is bodem
% 2 is vaste cell
% 3 is vrije cell

% testwereld initialisatie
data.wereld = zeros(11);
data.wereld(end,:) = 1;
data.wereld(1,1) = 3;
data.wereld(2,1) = 3;
% color map
colormap_fig = [0.184,0.592,0.756;
0.58,0.407,0.274;
0.823,0.972,0.596;
0.188,0.419,0.203;];

% Slider variablen
data.constante = 0
data.max_itteratie = 10
data.slider_timer = 0.5

% gui

screensize = get(0.0, "screensize")(3:4);
data.fig = figure(
  "name", "Biofilm growth",
  "numbertitle", "off",
  "units", "pixels",
  "position", [(screensize(1) - 1600) / 2, (screensize(2) - 900) / 2, 1600, 900],
  "menubar", "none",
  "color", [0.09, 0.09, 0.09]
);

data.axs = axes(
  "units", "pixels",
  "position", [200, 0, 1600, 900],
  "colormap", colormap_fig
);

% play butten
data.animation_toggle = uicontrol(
  "style", "pushbutton",
  "units", "pixels",
  "string", "|>",
  "tooltipstring",
  "Deze knop speelt de itteratie's van de wereld af op basis van de gekozen regel, hoeveelheid itteratie's en snelheid. ",
  "position", [50 ,100, 100, 50],
  "fontsize", 18,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596],
  "callback", @play_animation
);
% sluit venster butten
data.kill = uicontrol(
  "style", "pushbutton",
  "units", "pixels",
  "string", "Sluit venster",
  "tooltipstring", "Deze knop sluit alle venster die gemaakt zijn door dit programma",
  "position", [50,20,100,50],
  "fontsize", 13,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596],
  "callback", @kill_screen
  );

% Slider timer
data.timer_slider = uicontrol(
  "style", "slider",
  "units", "pixels",
  "string", "timer slider",
  "tooltipstring", "Slider time_delay ",
  "position", [0,175,200,20],
  "fontsize", 13,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596],
  "callback", @timer_slider
);
% static text
data.timer_text = uicontrol(
  "style", "text",
  "units", "pixels",
  "string", "Vertraging per seconde per iteratie",
  "position", [0,195,175,30],
  "fontsize", 8,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596]
);
% variable text
data.timer_variable = uicontrol(
  "style", "text",
  "units", "pixels",
  "string", "0.5",
  "position", [175,195,25,30],
  "fontsize", 8,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596]
);

% Slider itteratie
data.max_itteratie_slider = uicontrol(
  "style", "slider",
  "units", "pixels",
  "string", "timer slider",
  "tooltipstring", "Slider time_delay ",
  "position", [0,225,200,20],
  "fontsize", 13,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596],
  "callback", @itteratie_slider
);
% static text
data.itteratie_text = uicontrol(
  "style", "text",
  "units", "pixels",
  "string", "Maximum aantal itteraties",
  "position", [0,245,175,30],
  "fontsize", 8,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596]
);
% variable text
data.itteratie_variable = uicontrol(
  "style", "text",
  "units", "pixels",
  "string", "10",
  "position", [175,245,25,30],
  "fontsize", 8,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596]
);

% Slider constante
data.bio_constante_slider = uicontrol(
  "style", "slider",
  "units", "pixels",
  "string", "timer slider",
  "tooltipstring", "Slider time_delay ",
  "position", [0,270,200,20],
  "fontsize", 13,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596],
  "callback", @constante_slider
);
% static text
data.constante_text = uicontrol(
  "style", "text",
  "units", "pixels",
  "string", "Constante waarde biofilm",
  "position", [0,290,175,30],
  "fontsize", 8,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596]
);
% variable text
data.constante_variable = uicontrol(
  "style", "text",
  "units", "pixels",
  "string", "?",
  "position", [175,290,25,30],
  "fontsize", 8,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596]
);


% difusie text input
data.difusie_edit = uicontrol(
  "style", "edit",
  "units", "pixels",
  "string", "test",
  "position", [1,400,100,30],
  "fontsize", 8,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596]
);
% boundery layer text input

% pushknop standaard wereld
data.animation_toggle = uicontrol(
  "style", "pushbutton",
  "units", "pixels",
  "string", "Genereer standaard wereld",
  "tooltipstring",
  "Genereert de standaard wereld",
  "position", [0 ,700, 200, 50],
  "fontsize", 12,
  "foregroundcolor", [0.188,0.419,0.203],
  "backgroundcolor", [0.823,0.972,0.596],
  "callback", @generate_standaard
);


% display
data.img = imagesc(data.axs, data.wereld, [0, 3]);
axis(data.axs, "off");

% gui variable
guidata(data.fig, data);

function play_animation(source, event)
% Function play
%
  data = guidata(source);

for i = [1:data.max_itteratie]
  % circshift voor buren positie's
  underneibour = circshift(data.wereld,[-1,-1]);
  bovenneibour = circshift(data.wereld,[1,1]);
  % regels
  data.wereld(data.wereld == 3 & (underneibour == 0 | underneibour == 3)) = 0;
  data.wereld(data.wereld == 0 & bovenneibour == 3 & (underneibour == 1| underneibour == 2)) = 2;
  data.wereld(data.wereld == 0 & bovenneibour == 3) = 3;
  % variable vertraging voor dipslay
  pause(data.slider_timer)
  set(data.img,"cdata",data.wereld)
  guidata(source, data);
endfor
endfunction

function kill_screen(source, event)
  % close window
  close all
endfunction

function timer_slider(source, event)
  % timer slider functie
  data = guidata(source);
  timer = get(source,"Value");
  data.slider_timer = timer;
  set(data.timer_variable,"string", num2str(timer,2));
  guidata(source, data);
 endfunction

 function itteratie_slider(source, event)
  % max aantal itteratie functie
  data = guidata(source);
  slider_position = get(source,"Value");
  data.max_itteratie = round(slider_position *200);
  slider_string = int2str(data.max_itteratie);
  set(data.itteratie_variable, "string", slider_string);

 guidata(source, data);
endfunction

 function constante_slider(source, event)
  % constante slider functie
  data = guidata(source);
  slider_position = get(source,"Value");
  data.max_itteratie = slider_position *10;
  slider_string = num2str(data.max_itteratie,2);
  set(data.constante_variable, "string", slider_string);

 guidata(source, data);
endfunction

function generate_standaard(source, event)
  data = guidata(source);
  data.wereld = zeros(size(data.wereld));
  data.wereld(end,:) = 1;
  data.wereld(1,1) = 3;
  data.wereld(2,1) = 3;
  set(data.img, "cdata", data.wereld);
  guidata(source, data);
endfunction
