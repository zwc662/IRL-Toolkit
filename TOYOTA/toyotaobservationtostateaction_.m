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
speeds = [0, 20, 40, Inf];
spd = 0;
for i = 1:mdp_params.speed,
    if observation(2) <= speeds(i),
        spd = i;
        break;
    end;
end;
        

% Define car 1 lane coordinate
lane_1 = 0;
if observation(3) <= -41,
    lane_1 = 1;
else,
    lane_1 = 2;
end;

% Define car 1 distance coordiante
distances = [-30, -10, 10, 30, Inf]
dist_1 = 0;
for i = 1:mdp_params.distance,
    if observation(6) <= distances(i),
        dist_1 = i;
        break;
    end;
end;

% Define car 1 speed coordinate
speeds = [-30, -10, 10, Inf];
spd_1 = 0;
for i = 1:mdp_params.speed,
    if observation(5) <= speeds(i),
        spd_1 = i;
        break;
    end;
end;
        

% Define car 1 lane coordinate
lane_2 = 0;
if observation(6) <= -41,
    lane_2 = 1;
else,
    lane_2 = 2;
end;

% Define car 1 distance coordiante
distances = [-30, -10, 10, 30, Inf]
dist_2 = 0;
for i = 1:mdp_params.distance,
    if observation(7) <= distances(i),
        dist_1 = i;
        break;
    end;
end;

% Define car 1 speed coordinate
speeds = [-30, -10, 10, Inf];
spd_2 = 0;
for i = 1:mdp_params.speed,
    if observation(8) <= speeds(i),
        spd_2 = i;
        break;
    end;
end;

state = toyotacoordtostate(mdp_params,...
    lane, spd,...
    lane_1, dist_1, spd_1,...
    lane_2, dist_2, spd_2);
