% Construct the Toyota MDP structues.

function [mdp_data, r, feature_data, true_feature_map] =toyotabuild(mdp_params)

% mdp_params - parameters of the objectworld:
%       seed (0) - initialization for random seed
%       lanes (2) - number of lanes
%       distance(8) - relative distance to car 1
%       speed(6) - relative speeds to car 1    
%       num_cars 2 - total number of cars
%       determinism (1.0) - probability of correct transition
%       discount (0.9) - temporal discount factor to use
%
% mdp_data - standard MDP definition structure with object-world details:
%       states - total number of states in the MDP
%       actions - total number of actions in the MDP
%       discount - temporal discount factor to use
%       sa_s - mapping from state-action pairs to states
%       sa_p - mapping from state-action pairs to transition probabilities

% Fill in default parameters.
mdp_params = toyotadefaultparams(mdp_params);

% Set random seed.
rand('seed', mdp_params.seed);

% Constants.
states =  mdp_params.lanes * mdp_params.speed *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed;
fprintf("\nTotal number of states: %d\n", states);
actions = 6;

% Build action mappin.
sa_s = zeros(states, actions, actions);
sa_p = zeros(states, actions, actions);

count = 0;
lane_ = 0; spd_ = 0;...
lane_1_ = 0; dist_1_ = 0; spd_1_ = 0;
lane_2_ = 0; dist_2_ = 0; spd_2_ = 0;

for lane = 1:mdp_params.lanes,
    for spd = 1:mdp_params.speed,
        for lane_1 = 1:mdp_params.lanes,
            for dist_1 = 1:mdp_params.distance,
                for spd_1 = 1:mdp_params.speed,
                    for lane_2 = 1:mdp_params.lanes,
                        for dist_2 = 1:mdp_params.distance,
                            for spd_2 = 1:mdp_params.speed,
                                s = toyotacoordtostate(mdp_params,...
                                    lane, spd,...
                                    lane_1, dist_1, spd_1,...
                                    lane_2, dist_2, spd_2);
                                count = count + 1;
                                successors = zeros(1, 1, actions);
                                
                                lane_1_ = lane_1;
                                lane_2_ = lane_2;
                                
                                for action = 1: actions,
                                    
                                    if action > actions/2,
                                        lane_ = 1 + max(0, mdp_params.lanes - lane);
                                    else,
                                        lane_ = lane;
                                    end; 
                                    
                                    if mod(action, actions/2) == 1, %Accelerate
                                        dist_1_ = max(1, dist_1 - 1);
                                        spd_1_ = max(1, spd_1 - 1);
                                        dist_2_ = max(1, dist_2 - 1);
                                        spd_2_ = max(1, spd_2 - 1);
                                        spd_ = min(spd + 1, mdp_params.speed);
                                    elseif mod(action, actions/2) == 2, %Maintain speed
                                        dist_1_ = dist_1;
                                        spd_1_ = spd_1;
                                        dist_2_ = dist_2;
                                        spd_2_ = spd_2;
                                        spd_ = spd;
                                    elseif mod(action, actions/2) == 0, %Deccelearte
                                        dist_1_ = min(mdp_params.distance, dist_1 + 1);
                                        spd_1_ = min(mdp_params.speed, spd_1 + 1);
                                        dist_2_ = min(mdp_params.distance, dist_2 + 1);
                                        spd_2_ = min(mdp_params.speed, spd_2 + 1);
                                        spd_ = max(spd - 1, 1);
                                    end;
                                    
                                    if lane_ < 1 || lane_ > mdp_params.lanes ||...
                                            spd_ < 1 || spd_ > mdp_params.speed ||...
                                            lane_1_ < 1 || lane_1_ > mdp_params.lanes ||...
                                            dist_1_ < 1 || dist_1_ > mdp_params.distance ||...
                                            spd_1_ < 1 || spd_1_ > mdp_params.speed ||...
                                            lane_2_ < 1 || lane_2_ > mdp_params.lanes ||...
                                            dist_2_ < 1 || dist_2_ > mdp_params.distance ||...
                                            spd_2_ < 1 || spd_2_ > mdp_params.speed,
                                        fprintf("\nError>>>>Coord out of bound\n");
                                        disp([lane_ spd_ lane_1_ dist_1_ spd_1_ lane_2 dist_2_ spd_2_]);
                                    end;
                                    successors(1,1,action) = toyotacoordtostate(mdp_params, ...
                                            lane_, spd_, ...
                                            lane_1_, dist_1_, spd_1_,...
                                            lane_2_, dist_2_, spd_2_);
                                end;
                                % Naive select of the transition function
                                % The actions take effect immediately
                                sa_s(s,:,:) = repmat(successors,[1,actions,1]);
                 
                                % True transition function
                                % The actions almost never take effect
                                %successors = s * ones(1, actions, 1)
                                %sa_s(s,:,:) = repmat(successors,[1,actions,1]);

                                sa_p(s,:,:) = reshape(eye(actions,actions)*mdp_params.determinism +...
                                    (ones(actions,actions)-eye(actions,actions))*((1.0-mdp_params.determinism)/(actions - 1)),...
                                    1,actions,actions);  
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

fprintf("%d states has been processed", count);
fprintf('\nThis message is sent at time %s\n', datestr(now,'HH:MM:SS.FFF'))
% Create MDP data structure.
mdp_data = struct(...
    'states',states,...
    'actions',actions,...
    'discount',mdp_params.discount,...
    'determinism',mdp_params.determinism,...
    'sa_s',sa_s,...
    'sa_p',sa_p);

% Construct feature map.
[feature_data,true_feature_map,r] = toyotafeatures(mdp_params, mdp_data);
fprintf('This message is sent at time %s\n', datestr(now,'HH:MM:SS.FFF'))
