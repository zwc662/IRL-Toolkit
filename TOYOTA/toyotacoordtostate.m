% Utility function for covering coordinates to state indices.
function s = toyotacoordtostate(mdp_params,...
    lane, spd,...
    lane_1, dist_1, spd_1,...
    lane_2, dist_2, spd_2)
s = (lane - 1) * mdp_params.speed * ...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed +...
    (spd - 1) *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed +...
    (lane_1 - 1) * mdp_params.distance * mdp_params.speed *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed +...
    (dist_1 - 1) * mdp_params.speed *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed +...
    (spd_1 - 1) *...
    mdp_params.lanes * mdp_params.distance * mdp_params.speed +...
    (lane_2 - 1) * mdp_params.distance * mdp_params.speed +...
    (dist_2 - 1) * mdp_params.speed +...
    (spd_2 - 1) +...
    1;

if s <= 0,
    fprintf("\nError>>>>>>Negative state index\n")
    disp(s);
    disp([lane spd ...
    lane_1 dist_1 spd_1 ...
    lane_2 dist_2 spd_2]);
end;
