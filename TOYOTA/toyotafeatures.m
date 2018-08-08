% Construct the raw features for the toyota domain.
function [feature_data, true_feature_map, r] = toyotafeatures(mdp_params, mdp_data)

% mdp_params - definition of MDP domain
% mdp_data - generic definition of domain
% feature_data - generic feature data:
%   splittable - matrix of states to features
%   stateadjacency - sparse state adjacency matrix

% Fill in default parameters.
mdp_params = toyotadefaultparams(mdp_params);

% Construct adjacency table.
stateadjacency = sparse([], [], [], mdp_data.states, ...
    mdp_data.states * mdp_data.actions);
for s = 1:mdp_data.states,
    for a = 1:mdp_data.actions,
        if mdp_data.sa_s(s, a, 1) <= 0,
            disp([s  a mdp_data.sa_s(s, a, 1)]);
        end;
        stateadjacency(s, mdp_data.sa_s(s, a, 1)) = 1;
    end;
end;

% Construct split table.
% Features are the following:
% 1...lane - lane position of ego car
% 2...speed - speed of ego car
% 3...lane_1 - lane position of car1
% 4...dist_1 - relative distance to car1
% 5...spd_1 - relative speed of car1
% 6...lane_2 - lane position of car2
% 7...dist_2 - relative distance to car2
% 8...dist_c5 - relative speed of car2
% (For continuous)9...||s-s'||_2 - Euclid distance to 40 centroid points

f_lane = 1;
f_speed = f_lane + mdp_params.lanes;
f_lane_1 = f_speed + mdp_params.speed;
f_dist_1 = f_lane_1 + mdp_params.speed;
f_spd_1 = f_dist_1 + mdp_params.distance;
f_lane_2 = f_speed + mdp_params.speed;
f_dist_2 = f_lane_2 + mdp_params.lanes;
f_spd_2 = f_dist_2 + mdp_params.distance;
% f is the number of total number of features
f = f_spd_2 + mdp_params.speed - 1;

% (For continuous)Find f - 8 continuous centroids since there are only 8 coord features
centroids = floor(mdp_data.states/(f - 8)) * (1:(f - 8));
if length(centroids) ~= f - 8,
    fprintf("\nError>>>>>>Number of centroid is incorrect\n");
end;

% Discrete feature uses one-hot coding to indicate the features in binary.
splittable = zeros(mdp_data.states, f);
% Continuous feature just fill in the feature value
splittablecont = zeros(mdp_data.states, f);

for s = 1:mdp_data.states,
    [lane, spd,...
        lane_1, dist_1, spd_1,...
        lane_2, dist_2, spd_2] = toyotastatetocoord(s, mdp_params);
    
    % Write feature 1 ~ 8 to discrete feature table
    splittable(s, f_lane + lane - 1) = 1;
    splittable(s, f_speed + spd - 1) = 1;
    splittable(s, f_lane_1 + lane_1 - 1) = 1;
    splittable(s, f_dist_1 + dist_1 - 1) = 1;
    splittable(s, f_spd_1 + spd_1 - 1) = 1;
    splittable(s, f_lane_2 + lane_2 - 1) = 1;
    splittable(s, f_dist_2 + dist_2 - 1) = 1;
    splittable(s, f_spd_2 + spd_2 - 1) = 1;
    % (TBD) Write feature 9
    
    % Write normalized feature 1 ~ 8 to continuous feature table
    splittablecont(s, 1:8) = [lane/mdp_params.lanes spd/mdp_params.speed ...
        lane_1/mdp_params.lanes dist_1/mdp_params.distance spd_1/mdp_params.speed...
        lane_2/mdp_params.lanes dist_2/mdp_params.distance spd_2/mdp_params.speed];
    % Write remaining f - 8 centroid features
    splittablecont(s, 9:f) = abs(centroids - s)/mdp_data.states;
end;   


% Construct hand-made reward mapping
R_SCALE = 5;
r = zeros(mdp_data.states, 1);
for s = 1:mdp_data.states,
    [lane, spd,...
        lane_1, dist_1, spd_1,...
        lane_2, dist_2, spd_2] = toyotastatetocoord(s, mdp_params);
    % Be in the different lanes from other cars
    % Drive faster when being far away from other cars
    if (lane_1 ~= lane || lane_2 ~= lane) && (spd > 2) ||...
            (abs(dist_1 - mdp_params.distance/2) >= 1 && (spd_1 < (mdp_params.speed/2 - 1)) || ...
            abs(dist_2 - mdp_params.distance/2) >= 1 && (spd_2 < (mdp_params.speed/2 - 1))),
        r(s) = 1.0;
    end;
    
    % Don't be too slow when other cars are far away.
    % Don't drive too faster when other cars are too slow in the same lane.
    if (spd <= 2 && dist_1 >= mdp_params.distance - 1 && dist_2 >= mdp_params.distance - 1) ||...
            (lane_1 == lane && abs(dist_1 - mdp_params.distance/2) <= 1 && abs(spd_1 - mdp_params.speed/2) <= 1 ||...
            (lane_2 == lane && abs(dist_2 - mdp_params.distance/2) <= 1 && abs(spd_2 - mdp_params.speed/2) <= 1)),
        r(s) = -1.0;
    end;
end;    
    
r = repmat(r * R_SCALE,1,mdp_data.actions);    
feature_data = struct('stateadjacency',stateadjacency,'splittable',splittable);
if mdp_params.continuous,
    % Return continuous feature data structure.
    feature_data.splittable = splittablecont;
    feature_data.altsplittable = splittable;
    true_feature_map = splittable;
else,
    % Return discrete feature data structure.
    true_feature_map = splittablecont;
end;

fprintf("\nFeature built\nReward built\n");
    