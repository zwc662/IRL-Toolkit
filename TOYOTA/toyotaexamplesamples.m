function example_samples = toyotaexamplesamples(mdp_params)

% Load data table
data = load('TrainSet.mat', 'data');
[LENGTH, WIDTH] = size(data.data);

% Find the total number of time steps.
T = LENGTH/3;

% Build data table for each car
car = data.data(1:3:LENGTH, :);
car_1 = data.data(2:3:LENGTH, :);
car_2 = data.data(3:3:LENGTH, :);

% Build observation data table
observation_data = zeros(T, 8);

for t = 1:T,
    % lane position of ego car
    observation_data(t, 1) = car(t, 1);
    % speed of ego car
    observation_data(t, 2) = car(t, 4);
    % lane position of car_1;
    observation_data(t, 3) = car_1(t, 1);
    % relative distance of car_1;
    observation_data(t, 4) = car_1(t, 3) - car(t, 3);
    % relative speed of car_1;
    observation_data(t, 5) = car_1(t, 4) - car(t, 4);
    % lane position of car_2;
    observation_data(t, 6) = car_2(t, 1);
    % relative distance of car_1;
    observation_data(t, 7) = car_2(t, 3) - car(t, 3);
    % relative speed of car_1;
    observation_data(t, 8) = car_2(t, 4) - car(t, 4);
    % action;
    if t > 1,
        change_lane = int64(abs(car(t, 1) - car(t - 1, 1)) > 0) * 3;
    else,
        change_lane = 0;
    end;
    action = int64(change_lane + car(t, 5) - 2);
    observation_data(t, 9) = action;

end,


example_samples = cell(1, T);

for t = 1:T,
    % Turn each observation (including action) to state
    [s, a] = toyotaobservationtostateaction_(mdp_params, observation_data(t, :));
    example_samples{1, t} = [s;a];
end;