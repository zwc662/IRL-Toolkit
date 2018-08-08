% Utility function for covering observation to state indices.
function [state, action] = toyotaobservationtostateaction(mdp_params, observation)

action = observation(end);

coord = zeros(8);

% Define lane interval and find lane coordinate
lane = 0;
if observation(1) <= -41,
    lane = 1;
else,
    lane = 2;
end;

% Define speed interval and find speed coordinate
spd = 0;
if observation(2) <= 0,
    spd = 1;
elseif observation(2) > 0 && observation(2) <= 10,
    spd = 2;
elseif observation(2) > 10 && observation(2) <= 30,
    spd = 3;
elseif observation(2) > 30 && observation(2) <= 50,
    spd = 4;
elseif observation(2) > 50 && observation(2) <= 60,
    spd = 5;
elseif observation(2) > 60,
    spd = 6;
end;

% Define car 1 lane coordinate
lane_1 = 0;
if observation(3) <= -41,
    lane_1 = 1;
else,
    lane_1 = 2;
end;

% Define car 1 distance coordiante
dist_1 = 0;
if observation(4) <= -30.
    dist_1 = 1;
elseif observation(4) >-30 && observation(4) <= -20,
    dist_1 = 2;
elseif observation(4) >-20 && observation(4) <= -10,
    dist_1 = 3;
elseif observation(4) >-10 && observation(4) <= 0,
    dist_1 = 4;
elseif observation(4) >0 && observation(4) <= 10,
    dist_1 = 5;
elseif observation(4) >10 && observation(4) <= 20,
    dist_1 = 6;
elseif observation(4) >20 && observation(4) <= 30,
    dist_1 = 7;
elseif observation(4) >30,
    dist_1 = 8;
end;

% Define car 1 speed coordinate
spd_1 = 0;
if observation(5) <= -30,
    spd_1 = 1;
elseif observation(5) > -30 && observation(5) <= -10,
    spd_1 = 2;
elseif observation(5) > -10 && observation(5) <= 0,
    spd_1 = 3;
elseif observation(5) > 0 && observation(5) <= 10,
    spd_1 = 4;
elseif observation(5) > 10 && observation(5) <= 30,
    spd_1 = 5;
elseif observation(5) > 30,
    spd_1 = 6;
end;

% Define car 1 lane coordinate
lane_2 = 0;
if observation(6) <= -41,
    lane_2 = 1;
else,
    lane_2 = 2;
end;

% Define car 1 distance coordiante
dist_2 = 0;
if observation(7) <= -30.
    dist_2 = 1;
elseif observation(7) >-30 && observation(7) <= -20,
    dist_2 = 2;
elseif observation(7) >-20 && observation(7) <= -10,
    dist_2 = 3;
elseif observation(7) >-10 && observation(7) <= 0,
    dist_2 = 4;
elseif observation(7) >0 && observation(7) <= 10,
    dist_2 = 5;
elseif observation(7) >10 && observation(7) <= 20,
    dist_2 = 6;
elseif observation(7) >20 && observation(7) <= 30,
    dist_2 = 7;
elseif observation(7) >30,
    dist_2 = 8;
end;

% Define car 1 speed coordinate
spd_2 = 0;
if observation(8) <= -30,
    spd_2 = 1;
elseif observation(8) > -30 && observation(8) <= -10,
    spd_2 = 2;
elseif observation(8) > -10 && observation(8) <= 0,
    spd_2 = 3;
elseif observation(8) > 0 && observation(8) <= 10,
    spd_2 = 4;
elseif observation(8) > 10 && observation(8) <= 30,
    spd_2 = 5;
elseif observation(8) > 30,
    spd_2 = 6;
end;

state = toyotacoordtostate(mdp_params,...
    lane, spd,...
    lane_1, dist_1, spd_1,...
    lane_2, dist_2, spd_2);
